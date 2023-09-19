import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? raspberryPi;

  void _connectToRaspberryPi() async {
    // Start scanning for nearby Bluetooth devices
    flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == 'raspberrypi') {
        // Found the Raspberry Pi, stop scanning
        flutterBlue.stopScan();
        setState(() {
          raspberryPi = scanResult.device;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _connectToRaspberryPi,
              child: Text('Connect to Raspberry Pi'),
            ),
            Text('Connected to: ${raspberryPi?.name ?? 'None'}'),
          ],
        ),
      ),
    );
  }
}
