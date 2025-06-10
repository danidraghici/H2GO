
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'dart:typed_data';
// import 'package:permission_handler/permission_handler.dart';
//
//
// void main() => runApp(BluetoothApp());
//
// class BluetoothApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bluetooth Serial Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: BluetoothHome(),
//     );
//   }
// }
//
// class BluetoothHome extends StatefulWidget {
//   @override
//   _BluetoothHomeState createState() => _BluetoothHomeState();
// }
//
// class _BluetoothHomeState extends State<BluetoothHome> {
//   BluetoothDevice? selectedDevice;
//   BluetoothConnection? connection;
//   bool isConnecting = false;
//   String receivedData = "";
//
//   @override
//   void initState() {
//     super.initState();
//     requestBluetoothPermissions().then((granted) {
//       if (granted) {
//         FlutterBluetoothSerial.instance.requestEnable();
//       } else {
//         print("Permisiuni Bluetooth refuzate!");
//       }
//     });
//     // FlutterBluetoothSerial.instance.requestEnable();
//   }
//
//   Future<bool> requestBluetoothPermissions() async {
//     if (await Permission.bluetoothScan.request().isGranted &&
//         await Permission.bluetoothConnect.request().isGranted &&
//         await Permission.locationWhenInUse.request().isGranted) {
//       return true;
//     }
//     return false;
//   }
//
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     setState(() {
//       isConnecting = true;
//     });
//
//     try {
//       BluetoothConnection newConnection =
//       await BluetoothConnection.toAddress(device.address);
//       print('✅ Connected to ${device.name}');
//       setState(() {
//         connection = newConnection;
//         selectedDevice = device;
//       });
//
//       connection?.input?.listen((Uint8List data) {
//         setState(() {
//           receivedData += utf8.decode(data);
//         });
//       });
//     } catch (e) {
//       print('❌ Eroare la conectare: $e');
//       setState(() {
//         connection = null;
//       });
//     } finally {
//       setState(() {
//         isConnecting = false;
//       });
//     }
//   }
//
//   Future<List<BluetoothDevice>> getBondedDevices() async {
//     return await FlutterBluetoothSerial.instance.getBondedDevices();
//   }
//
//   void sendMessage(String message) {
//     if (connection != null && connection!.isConnected) {
//       connection!.output.add(utf8.encode(message + "\n"));
//     }
//   }
//
//   @override
//   void dispose() {
//     connection?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Serial'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(
//               child: Text('🔍 Afișează dispozitive împerecheate'),
//               onPressed: () async {
//                 List<BluetoothDevice> devices = await getBondedDevices();
//                 showDialog(
//                   context: context,
//                   builder: (context) => SimpleDialog(
//                     title: Text("Selectează dispozitiv"),
//                     children: devices
//                         .map((device) => SimpleDialogOption(
//                       child: Text("${device.name} (${device.address})"),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         connectToDevice(device);
//                       },
//                     ))
//                         .toList(),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 20),
//             Text(
//               selectedDevice == null
//                   ? "⚠️ Niciun dispozitiv conectat"
//                   : "✅ Conectat la ${selectedDevice!.name}",
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 10),
//             if (connection?.isConnected ?? false)
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       onSubmitted: sendMessage,
//                       decoration: InputDecoration(
//                         labelText: "Trimite un mesaj",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             SizedBox(height: 20),
//             Text("📨 Date primite:", style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Text(receivedData),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ///////////////////
//
//
//


//


//
//
// //ASTA E OK
//
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bluetooth Retry Demo',
//       home: BluetoothPage(),
//     );
//   }
// }
//
// class BluetoothPage extends StatefulWidget {
//   @override
//   _BluetoothPageState createState() => _BluetoothPageState();
// }
//
// class _BluetoothPageState extends State<BluetoothPage> {
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
//   BluetoothDevice? selectedDevice;
//   BluetoothConnection? connection;
//   String receivedData = '';
//   bool isConnecting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() => _bluetoothState = state);
//     });
//
//     FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
//       setState(() => _bluetoothState = state);
//     });
//
//     _enableBluetooth();
//   }
//
//   Future<void> _enableBluetooth() async {
//     if (_bluetoothState == BluetoothState.STATE_OFF) {
//       await FlutterBluetoothSerial.instance.requestEnable();
//     }
//   }
//
//   Future<void> connectWithRetry(BluetoothDevice device) async {
//     const int maxRetries = 30;
//     int retryCount = 0;
//     bool connected = false;
//
//     setState(() => isConnecting = true);
//
//     while (!connected && retryCount < maxRetries) {
//       try {
//         connection = await BluetoothConnection.toAddress(device.address);
//         print('✅ Conectat la ${device.name}');
//         setState(() {
//           selectedDevice = device;
//         });
//         connected = true;
//
//         connection?.input?.listen((Uint8List data) {
//           setState(() {
//             receivedData += utf8.decode(data);
//           });
//         });
//       } catch (e) {
//         retryCount++;
//         print('❌ Conectare eșuată (încercare $retryCount): $e');
//         await Future.delayed(Duration(seconds: 2));
//       }
//     }
//
//     if (!connected) {
//       print('❌ Conexiune eșuată după $maxRetries încercări');
//       setState(() {
//         selectedDevice = null;
//       });
//     }
//
//     setState(() => isConnecting = false);
//   }
//
//   Future<void> selectDeviceAndConnect() async {
//     final BluetoothDevice? device = await FlutterBluetoothSerial.instance
//         .getBondedDevices()
//         .then((List<BluetoothDevice> bondedDevices) async {
//       return await showDialog<BluetoothDevice>(
//         context: context,
//         builder: (context) {
//           return SimpleDialog(
//             title: Text("Alege un dispozitiv"),
//             children: bondedDevices
//                 .map((d) => SimpleDialogOption(
//               child: Text(d.name ?? d.address),
//               onPressed: () => Navigator.pop(context, d),
//             ))
//                 .toList(),
//           );
//         },
//       );
//     });
//
//     if (device != null) {
//       await connectWithRetry(device);
//     }
//   }
//
//   @override
//   void dispose() {
//     connection?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Retry Demo'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text('Bluetooth este: ${_bluetoothState.toString()}'),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: isConnecting ? null : selectDeviceAndConnect,
//               child: Text(isConnecting ? 'Se conectează...' : 'Conectează-te'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Date primite:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Text(receivedData),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
import 'package:flutter/material.dart';
import 'package:untitled/screen/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 100, color: Colors.teal[800]),
            SizedBox(height: 20),
            Text(
              "Welcome to H2GO",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[800]),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.teal),
          ],
        ),
      ),
    );
  }
}


//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//
// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: BluetoothTemperatureScreen(),
//   ));
// }
//
// class BluetoothTemperatureScreen extends StatefulWidget {
//   @override
//   _BluetoothTemperatureScreenState createState() => _BluetoothTemperatureScreenState();
// }
//
// class _BluetoothTemperatureScreenState extends State<BluetoothTemperatureScreen> {
//   BluetoothConnection? connection;
//   String connectedDevice = "";
//   double temperature = 0.0;
//   Timer? timer;
//
//   @override
//   void initState() {
//     super.initState();
//     connectToBluetoothDevice();
//   }
//
//   Future<void> connectToBluetoothDevice() async {
//     try {
//       bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
//       if (isEnabled == false) {
//         await FlutterBluetoothSerial.instance.requestEnable();
//       }
//
//       List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
//
//       if (devices.isEmpty) {
//         print("❌ Nu există dispozitive Bluetooth paired");
//         return;
//       }
//
//       BluetoothDevice selectedDevice = devices.first;
//       connectedDevice = selectedDevice.name ?? selectedDevice.address;
//
//       connection = await BluetoothConnection.toAddress(selectedDevice.address);
//       print('✅ Conectat la ${selectedDevice.name} (${selectedDevice.address})');
//
//       connection!.input!.listen((Uint8List data) {
//         String incoming = utf8.decode(data).trim();
//         print('📡 Date primite: $incoming');
//
//         double? temp = double.tryParse(incoming);
//         if (temp != null) {
//           setState(() {
//             temperature = temp;
//           });
//         }
//       }).onDone(() {
//         print('🔌 Conexiune închisă');
//       });
//
//       timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
//         setState(() {}); // Trigger UI update
//       });
//
//       setState(() {});
//
//     } catch (e) {
//       print("❌ Eroare la conectare: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     connection?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Temperatură Bluetooth")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             if (connectedDevice.isNotEmpty)
//               Text("✅ Conectat la: $connectedDevice", style: TextStyle(fontSize: 16)),
//             SizedBox(height: 20),
//             Text(
//               "Temperatură: ${temperature.toStringAsFixed(1)} °C",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }