import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'BluetoothDeviceListEntry.dart';
import 'DetailsPage.dart';
void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget  {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:HomePage(),debugShowCheckedModeBanner: false,);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  List<BluetoothDevice> devices = [];


  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getBTState();
    _stateChangeListener();
    _listBondedDevices();
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleChange(AppLifecycleState state){
    if(state == 0){
      //resume the loading
      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      }
    }
  }
  _getBTState(){
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      }
      setState(() {});
    });
  }

  _stateChangeListener(){
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      _bluetoothState =state;
      if(_bluetoothState.isEnabled){
        _listBondedDevices();
      }
      else{
        devices.clear();
      }
      print("State is enabled ${state.isEnabled}");
      setState(() {
      });
    });
  }

  _listBondedDevices(){
    FlutterBluetoothSerial.instance.getBondedDevices().then( (List<BluetoothDevice> bondedDevices){
      devices = bondedDevices;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Rasperberry pi bluetooth serial"),),
      body: Container(
        child: Column(children: <Widget>[
          SwitchListTile(
              title: Text("Enable Bluetooth"),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value){
                future() async{
                  if(value){
                    await FlutterBluetoothSerial.instance.requestEnable();
                  }
                  else{
                    await FlutterBluetoothSerial.instance.requestDisable();
                  }
                  future().then((_) {
                    setState(() {});
                  });
                }
              },
          ),
          ListTile(
            title: Text("Bluetooth Status"),
            subtitle: Text(_bluetoothState.toString()),
            trailing: ElevatedButton(
              child: Text("Settings"),
              onPressed: (){
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ),
        Text("Bonded Devices List:"),
          Expanded(
              child: ListView(
                children: devices
                    .map((_device) => BluetoothDeviceListEntry(
                          device: _device ,
                          enabled: true,
                          onTap: () {
                            print("Item");
                            _startConnectingtoPI(context, _device);
                            },)
                ).toList(),
          ),
          )
        ],
        ),
      ),
    );
  }
  void _startConnectingtoPI(BuildContext context, BluetoothDevice server){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return DetailPage(server: server,);
    }));
  }
}

