import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'databasehelper.dart';
import 'chartspage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DetailPage extends StatefulWidget {


  final BluetoothDevice server;
  const DetailPage({required this.server});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  BluetoothConnection? connection ;
  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;
  String receivedData = "No Data";
  List<PiDataModel>  databaseData= [];

  @override
  initState(){
    super.initState();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  dispose(){
    if(isConnected){
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  Future<void> downloadCsv() async {
    final dbHelper = PiDatabase.instance;
    final result = await dbHelper.getdata();

    final List<List<dynamic>> rows = [];

    // Convert PiDataModel objects to lists of values
    for (var data in result) {
      rows.add([
        data.timeStamp,
        data.temperature,
        data.random,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    // Request permission to access the selected directory
    final status = await Permission.storage.request();
    if (status.isGranted) {
      // Use the file picker to choose the folder location to save the file
      String? result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        final folderPath = result;

        final file = File('$folderPath/pi_data.csv');
        await file.writeAsString(csvData);

        // Show a dialog or snackbar to inform the user that the download is complete.
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('CSV Downloaded'),
              content: Text('CSV file has been downloaded successfully to $folderPath/pi_data.csv'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle the case where the user cancels the folder selection.
        // You can show a message to inform the user.
      }
    } else {
      // Handle the case where permission is not granted.
      // You can show a message to inform the user.
    }
  }

  Future<void> _onDataReceived(Uint8List data) async{
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    String dataString = String.fromCharCodes(buffer);
    setState(() {
      receivedData = dataString;
    });
    final jsonData = json.decode(dataString);
    //Storing data in database
    final dbHelper =  PiDatabase.instance;
    // Make changes based attribute names here
    var dataObj =  PiDataModel(
      timeStamp: jsonData["timeStamp"],
      temperature: jsonData["temperature"],
      random: jsonData["random"],
    );
    dbHelper.insertdata(dataObj);
    //Display data from database
    final result = await dbHelper.getdata();
    setState(() {
      databaseData = result;
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isConnecting
              ? 'Connecting to ${widget.server.name}....'
              : isConnected
              ? 'Connected to ${widget.server.name}'
              : 'Disconnected from ${widget.server.name}',
        ),
      ),
      body: SafeArea(
        child: isConnected
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Real-time Data',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              receivedData,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20), // Add margin left and right
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      downloadCsv();
                    },
                    child: Text('Download CSV'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16), // Adjust button padding
                    ),
                  ),
                  SizedBox(height: 10), // Add spacing between buttons
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChartsPage(databaseData: databaseData),
                        ),
                      );
                    },
                    child: Text('View Charts'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16), // Adjust button padding
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Connecting ....",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }


}
