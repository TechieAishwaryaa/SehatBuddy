# import numpy as np
# import tensorflow as tf

# acc_interpreter = tf.lite.Interpreter(model_path="models/acc_model.tflite")
# gyro_interpreter = tf.lite.Interpreter(model_path="models/gyro_model.tflite")

# acc_interpreter.allocate_tensors()
# gyro_interpreter.allocate_tensors()

# acc_input_details = acc_interpreter.get_input_details()
# acc_output_details = acc_interpreter.get_output_details()

# gyro_input_details = gyro_interpreter.get_input_details()
# gyro_output_details = gyro_interpreter.get_output_details()

# def predict_tflite(interpreter, input_data, input_details, output_details):
#     interpreter.set_tensor(input_details[0]['index'], input_data.astype('float32'))
#     interpreter.invoke()
#     output = interpreter.get_tensor(output_details[0]['index'])
#     return float(output[0][0])

# from fastapi import FastAPI
# import numpy as np

# app = FastAPI()
# THRESHOLD = 0.64

# @app.post("/predict")
# def predict(data: dict):

#     acc = np.array(data["accelerometer"]).reshape(1, 50, 3)
#     gyro = np.array(data["gyroscope"]).reshape(1, 50, 3)

#     print("\n--- NEW REQUEST ---")
#     print("ACC SAMPLE:", acc[0][20:25])
#     print("GYRO SAMPLE:", gyro[0][20:25])

#     prob_acc = predict_tflite(acc_interpreter, acc, acc_input_details, acc_output_details)
#     prob_gyro = predict_tflite(gyro_interpreter, gyro, gyro_input_details, gyro_output_details)

#     final_prob = (prob_acc + prob_gyro) / 2

#     print("Prob Acc:", prob_acc)
#     print("Prob Gyro:", prob_gyro)
#     print("Final Prob:", final_prob)

#     return {
#         "prob_acc": prob_acc,
#         "prob_gyro": prob_gyro,
#         "final_prob": final_prob,
#         "fall_detected": final_prob >= THRESHOLD
#     }

# from fastapi.middleware.cors import CORSMiddleware

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )




import numpy as np
import tensorflow as tf
import joblib
import time
from collections import deque
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# =========================
# LOAD MODELS
# =========================
acc_interpreter = tf.lite.Interpreter(model_path="models/acc_model.tflite")
gyro_interpreter = tf.lite.Interpreter(model_path="models/gyro_model.tflite")

acc_interpreter.allocate_tensors()
gyro_interpreter.allocate_tensors()

acc_input_details = acc_interpreter.get_input_details()
acc_output_details = acc_interpreter.get_output_details()

gyro_input_details = gyro_interpreter.get_input_details()
gyro_output_details = gyro_interpreter.get_output_details()

# =========================
# LOAD SCALERS
# =========================
scaler_acc = joblib.load("models/scaler_acc.pkl")
scaler_gyro = joblib.load("models/scaler_gyro.pkl")

# =========================
# GLOBAL VARIABLES (STATE)
# =========================
window = deque(maxlen=30)   # rolling probabilities
prev_prob = 0.0

alpha = 0.6        # smoothing factor
k = 1.5            # threshold multiplier
cooldown_time = 3  # seconds
last_fall_time = 0

# =========================
# FASTAPI SETUP
# =========================
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# HELPER FUNCTION
# =========================
def predict_tflite(interpreter, input_data, input_details, output_details):
    interpreter.set_tensor(input_details[0]['index'], input_data.astype('float32'))
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    return float(output[0][0])

# =========================
# MAIN API
# =========================
@app.post("/predict")
def predict(data: dict):

    global prev_prob, last_fall_time

    # -------------------------
    # INPUT
    # -------------------------
    acc = np.array(data["accelerometer"]).reshape(1, 50, 3)

    gyro_data = data.get("gyroscope", None)

    gyro_available = True

    if gyro_data is None:
        gyro_available = False
        gyro = None
    else:
        gyro = np.array(gyro_data).reshape(1, 50, 3)

    # Check if gyro is "dead" (no variation)
        gyro_std = np.std(gyro)

        if gyro_std < 0.01:
            gyro_available = False

    # -------------------------
    # APPLY SCALING
    # -------------------------
    # -------------------------
# APPLY SCALING
# -------------------------
    acc_reshaped = acc.reshape(-1, 3)
    acc_scaled = scaler_acc.transform(acc_reshaped).reshape(1, 50, 3)

    if gyro_available:
        gyro_reshaped = gyro.reshape(-1, 3)
        gyro_scaled = scaler_gyro.transform(gyro_reshaped).reshape(1, 50, 3)

    # -------------------------
    # MODEL PREDICTION
    # -------------------------
    prob_acc = predict_tflite(
        acc_interpreter, acc_scaled, acc_input_details, acc_output_details
    )

    if gyro_available:
        prob_gyro = predict_tflite(
            gyro_interpreter, gyro_scaled, gyro_input_details, gyro_output_details
        )
        final_prob = (prob_acc + prob_gyro) / 2
    else:
        prob_gyro = 0.0
        final_prob = prob_acc

    # -------------------------
    # SMOOTHING
    # -------------------------
    smoothed_prob = alpha * final_prob + (1 - alpha) * prev_prob
    prev_prob = smoothed_prob

    # -------------------------
    # UPDATE WINDOW
    # -------------------------
    window.append(smoothed_prob)

    # -------------------------
    # DYNAMIC THRESHOLD
    # -------------------------
    if len(window) >= 10:
        mean = np.mean(window)
        std = np.std(window)
        threshold = float(mean + k * std)
    else:
        threshold = 0.5  # initial fallback

    # -------------------------
    # SPIKE DETECTION
    # -------------------------
    delta = smoothed_prob - (window[-2] if len(window) > 1 else smoothed_prob)

    spike = delta > 0.05

    # -------------------------
    # FINAL FALL LOGIC
    # -------------------------
    current_time = time.time()

    fall = False
    if smoothed_prob > threshold and spike:
        if current_time - last_fall_time > cooldown_time:
            fall = True
            last_fall_time = current_time

    # -------------------------
    # DEBUG PRINTS
    # -------------------------
    print("\n--- NEW REQUEST ---")
    print("Prob Acc:", prob_acc)
    print("Prob Gyro:", prob_gyro)
    print("Final Prob:", final_prob)
    print("Smoothed Prob:", smoothed_prob)
    print("Threshold:", threshold)
    print("Delta:", delta)
    print("Fall:", fall)

    # -------------------------
    # RESPONSE (FIXED ERROR)
    # -------------------------
    return {
        "prob_acc": float(prob_acc),
        "prob_gyro": float(prob_gyro),
        "final_prob": float(final_prob),
        "smoothed_prob": float(smoothed_prob),
        "threshold": float(threshold),
        "fall_detected": bool(fall)   # ✅ FIXED numpy.bool_ error
    }