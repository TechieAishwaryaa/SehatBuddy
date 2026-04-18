import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String status = "Click button to test";

  // NORMAL DATA
  final List<List<double>> normalAcc = [
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4],
    [0.3, 0.2, 0.6],
    [0.2, 0.3, 0.5],
    [0.1, 0.2, 0.4]
  ];

  final List<List<double>> normalGyro = [
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01],
    [0.02, 0.01, 0.02],
    [0.01, 0.02, 0.01]
  ];
  // FALL DATA (SPIKE)
  List<List<double>> fallAcc = List.generate(50, (i) {
    if (i == 25) return [20.0, 20.0, 20.0]; // VERY BIG SPIKE
    return [0.05, 0.05, 0.05];
  });

  List<List<double>> fallGyro = List.generate(50, (i) {
    if (i == 25) return [10.0, 10.0, 10.0];
    return [0.001, 0.001, 0.001];
  });

  Future<void> sendData(List acc, List gyro) async {
    try {
      //var url = Uri.parse("http://127.0.0.1:8000/predict");
      var url = Uri.parse("http://192.168.0.104:8000/predict");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"accelerometer": acc, "gyroscope": gyro}),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("Sending ACC: ${acc[20]}");
        print("Sending GYRO: ${gyro[20]}");
        print("Response: ${response.body}");
        setState(() {
          status = "Prob: ${result['final_prob']}";
        });

        if (result["fall_detected"] == true) {
          showAlert("Fall Detected!");
        } else {
          showAlert("Normal Activity");
        }
      } else {
        setState(() {
          status = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
      print(e);
    }
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fall Detection Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                print("CLICKED NORMAL");
                sendData(normalAcc, normalGyro);
              },
              child: const Text("Test NORMAL"),
            ),
            ElevatedButton(
              onPressed: () {
                print("CLICKED FALL");
                sendData(fallAcc, fallGyro);
              },
              child: const Text("Test FALL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LiveSensorScreen()),
                );
              },
              child: const Text("Go to LIVE Detection"),
            ),
          ],
        ),
      ),
    );
  }
}





class LiveSensorScreen extends StatefulWidget {
  @override
  _LiveSensorScreenState createState() => _LiveSensorScreenState();
}

class _LiveSensorScreenState extends State<LiveSensorScreen> {
  List<List<double>> accData = [];
  List<List<double>> gyroData = [];

  String status = "Collecting data...";
  Timer? timer;
  bool alertShown = false;

  @override
  void initState() {
    super.initState();

    // 📌 Collect accelerometer
    accelerometerEvents.listen((event) {
      accData.add([event.x, event.y, event.z]);
      if (accData.length > 50) accData.removeAt(0);
    });

    // 📌 Collect gyroscope
    gyroscopeEvents.listen((event) {
      gyroData.add([event.x, event.y, event.z]);
      if (gyroData.length > 50) gyroData.removeAt(0);
    });

    // 📌 Send every 3 sec
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (accData.length == 50 && gyroData.length == 50) {
        sendLiveData();
      }
    });
  }

  Future<void> sendLiveData() async {
    try {
      var url = Uri.parse("http://10.89.182.182:8000/predict");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "accelerometer": accData,
          "gyroscope": gyroData
        }),
      );

      var result = jsonDecode(response.body);

      setState(() {
        status = "Prob: ${result['final_prob'].toStringAsFixed(2)}";
      });

      if (result["fall_detected"] == true && !alertShown) {
        alertShown = true;
        showAlert();
      }

      if (result["fall_detected"] == false) {
        alertShown = false;
      }

    } catch (e) {
      setState(() {
        status = "Error sending data";
      });
    }
  }

  void showAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("⚠ Fall Detected"),
        content: const Text("Possible fall detected!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              alertShown = false;
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Detection")),
      body: Center(
        child: Text(
          status,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}