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
import 'dart:convert';
import 'dart:async';

class DataFetcher {
  void fetchData() {
    // Your data fetching logic here
    print('Fetching data...');
  }
}




class DetailPage extends StatefulWidget {


  final BluetoothDevice server;
  const DetailPage({required this.server});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  BluetoothConnection? connection ;
  bool isConnecting = true;
  bool sync = false;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;
  String receivedData = "No Data";
  List<PiDataModel>  databaseData= [];

  late Timer dataTimer;
  Duration refreshRate = const Duration(seconds: 1);

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
      startDataFetching();
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


  void startDataFetching() {
    _sendMessage("nosync");
    dataTimer = Timer.periodic(refreshRate, (Timer t) {
      _sendMessage("nosync"); // Fetch data periodically
    });
  }

  void pauseDataFetching() {
    if (dataTimer.isActive) {
      dataTimer.cancel();
    }
  }

  void resumeDataFetching() {
    if (!dataTimer.isActive) {
      dataTimer = Timer.periodic(refreshRate, (Timer t) {
        _sendMessage("nosync"); // Resume periodic data fetching
      });
    }
  }

  void _sendMessage(String text) async {
    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        await connection!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
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

  Future<void> _onDataReceived(Uint8List data) async {
    String dataString = ascii.decode(data);
    setState(() {
      receivedData = dataString;
    });

    if(dataString.length == 9){
      resumeDataFetching();
      setState(() {
        receivedData = "Started Fetching New Data";
      });
    }
    else {
      final jsonData = json.decode(dataString);
      final dbHelper = PiDatabase.instance;

      if (jsonData is List) {
        final List<PiDataModel> piDataModels = [];
        for (var jsonDataPoint in jsonData) {
          PiDataModel dataModel = PiDataModel(
            timeStamp: jsonDataPoint['timeStamp'],
            temperature: jsonDataPoint['temperature'],
            random: jsonDataPoint['random'],
          );
          piDataModels.add(dataModel);
        }
        await dbHelper.insertMultipleData(piDataModels);

      }
      else {
        setState(() {
          receivedData = dataString;
        });

        var dataObj = PiDataModel(
          timeStamp: jsonData["timeStamp"],
          temperature: jsonData["temperature"],
          random: jsonData["random"],
        );

        await dbHelper.insertdata(dataObj);
      }
    }
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
      body: Center(
        child: Scrollbar( // Wrap your ListView with Scrollbar
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [SafeArea(
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
                            pauseDataFetching();
                            _sendMessage("sync");
                          },
                          child: Text('Sync All Data'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(16), // Adjust button padding
                          ),
                        ),
                        SizedBox(height: 10),
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
                          onPressed: () async {
                            // Call getdata() to retrieve data from the database
                            final List<PiDataModel> databaseDatas = await PiDatabase.instance.getdata();

                            // Navigate to ChartsPage and pass the retrieved data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChartsPage(databaseData: databaseDatas),
                              ),
                            );
                          },
                          child: Text('View Charts'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(16),
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
            )
            ],
          ),
        ),
      ),
    );
  }


}



