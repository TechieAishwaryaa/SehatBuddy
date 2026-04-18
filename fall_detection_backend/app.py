import numpy as np
import tensorflow as tf

acc_interpreter = tf.lite.Interpreter(model_path="models/acc_model.tflite")
gyro_interpreter = tf.lite.Interpreter(model_path="models/gyro_model.tflite")

acc_interpreter.allocate_tensors()
gyro_interpreter.allocate_tensors()

acc_input_details = acc_interpreter.get_input_details()
acc_output_details = acc_interpreter.get_output_details()

gyro_input_details = gyro_interpreter.get_input_details()
gyro_output_details = gyro_interpreter.get_output_details()

def predict_tflite(interpreter, input_data, input_details, output_details):
    interpreter.set_tensor(input_details[0]['index'], input_data.astype('float32'))
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    return float(output[0][0])

from fastapi import FastAPI
import numpy as np

app = FastAPI()
THRESHOLD = 0.64

@app.post("/predict")
def predict(data: dict):

    acc = np.array(data["accelerometer"]).reshape(1, 50, 3)
    gyro = np.array(data["gyroscope"]).reshape(1, 50, 3)

    print("\n--- NEW REQUEST ---")
    print("ACC SAMPLE:", acc[0][20:25])
    print("GYRO SAMPLE:", gyro[0][20:25])

    prob_acc = predict_tflite(acc_interpreter, acc, acc_input_details, acc_output_details)
    prob_gyro = predict_tflite(gyro_interpreter, gyro, gyro_input_details, gyro_output_details)

    final_prob = (prob_acc + prob_gyro) / 2

    print("Prob Acc:", prob_acc)
    print("Prob Gyro:", prob_gyro)
    print("Final Prob:", final_prob)

    return {
        "prob_acc": prob_acc,
        "prob_gyro": prob_gyro,
        "final_prob": final_prob,
        "fall_detected": final_prob >= THRESHOLD
    }

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)