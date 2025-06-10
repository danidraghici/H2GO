import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/screen/login.dart';
import 'package:untitled/screen/programari.dart';

import 'about.dart';
import 'alerte.dart';
import 'istoricMasuratori.dart';
import 'medicatie.dart';

Timer? _sendTimer;
class BluetoothApp extends StatelessWidget {
  final String name;
  final String photoUrl;
  final String role;
  final String email;
  final String cnp;
  final  user;

  BluetoothApp({
    required this.name,
    required this.photoUrl,
    required this.role,
    required this.email,
    required this.cnp,
    required this.user,
  });


  // Widget buildDrawer(String role,BuildContext context) {
  //   Drawer(
  //     child: ListView(
  //       padding: EdgeInsets.zero,
  //       children: [
  //         UserAccountsDrawerHeader(
  //           accountName: Text(name),
  //           accountEmail: Text(email),
  //           currentAccountPicture: CircleAvatar(
  //             backgroundColor: Colors.white,
  //             child: Icon(Icons.person, color: Colors.blue),
  //           ),
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.calendar_today),
  //           title: Text('Programări'),
  //           onTap: () {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(
  //                   builder: (_) => ProgramariPage(cnp: '6090901990011')),
  //             );
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.logout),
  //           title: Text('Deconectare'),
  //           onTap: () {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(builder: (_) => LoginPage()),
  //             );
  //           },
  //         ), ListTile(
  //           leading: Icon(Icons.medical_information),
  //           title: Text('Medicatie'),
  //           onTap: () {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(
  //                   builder: (_) => MedicalFilePage(cnp: '6020220234523')),
  //             );
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.notification_important),
  //           title: Text('Istoric alerte'),
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (_) => AlertHistoryPage(cnp: '6090901990011')),
  //             );
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.notification_important),
  //           title: Text('Istoric masuratori'),
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (_) => HistoryPage(cnp: '6090901990011')),
  //             );
  //           },
  //         ),
  //
  //       ],
  //     ),
  //   );
  // }
  //


  @override
  Widget build(BuildContext context) {
    Widget buildDrawer(String role) {
      switch (role) {
        case 'pacient':
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Programări'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProgramariPage(cnp: cnp)),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.medical_information),
                  title: Text('Medicatie'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MedicalFilePage(cnp: cnp)),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notification_important),
                  title: Text('Istoric alerte'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AlertHistoryPage(cnp: cnp)),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notification_important),
                  title: Text('Istoric masuratori'),
                  onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryPage(cnp: cnp))
              );
            }
          ),
                ListTile(
                    leading: Icon(Icons.person_3_outlined),
                    title: Text('Despre mine'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PacientProfilePage(
                            nume: name ?? '',
                            email:email ?? '',
                            cnp: cnp ?? '',
                            telefon: user['Telefon'] ?? '',
                            adresa: user['Adresa'] ?? '',
                            dataNasterii: user['Data_nasterii'] ?? '',
                            sex: user['Sex'] ?? '',
                            medicCurant: user['CNP_medic'] ?? ''))
                      );
                    }
                ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Deconectare'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                    )
      ],
      ),
      );
          break;
        case 'ingrijitor':
          return  Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Programări pacient'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProgramariPage(cnp: cnp),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.medical_information),
                  title: Text('Medicatie'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MedicalFilePage(cnp: cnp)),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notification_important),
                  title: Text('Istoric alerte'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AlertHistoryPage(cnp: cnp)),
                    );
                  },
                ),
                ListTile(
                    leading: Icon(Icons.notification_important),
                    title: Text('Istoric masuratori'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HistoryPage(cnp: cnp))
                      );
                    }
                ),
                // ListTile(
                //   leading: Icon(Icons.calendar_today),
                //   title: Text('Dashboard pacient'),
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (_) => BluetoothApp( name:  name ?? 'Pacient',
                //             photoUrl: 'https://i.pravatar.cc/150?img=1',
                //             role: role,
                //             email: email ?? 'DoctorNou@gmail.com',
                //             cnp: '6090901990011',),
                //       ),
                //     );
                //   },
                // ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Deconectare'),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          );
        default :    throw Exception("Rol necunoscut: $role");
      }

    }
    return MaterialApp(
      title: 'H2GO',
      theme: ThemeData(primarySwatch: Colors.blue),
      // routes: {
      //   '/programari': (context) => ProgramariPage(),
      //   // '/login': (context) => LoginPage(), // Asigură-te că ai definit-o
      // },
      home: Scaffold(
        appBar: AppBar(title: Text('H2GO Home Pacient')),
          drawer: buildDrawer(role),
        //   Drawer(
        //   child: ListView(
        //     padding: EdgeInsets.zero,
        //     children: [
        //       UserAccountsDrawerHeader(
        //         accountName: Text(name),
        //         accountEmail: Text(email),
        //         currentAccountPicture: CircleAvatar(
        //           backgroundColor: Colors.white,
        //           child: Icon(Icons.person, color: Colors.blue),
        //         ),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.calendar_today),
        //         title: Text('Programări'),
        //         onTap: () {
        //           Navigator.of(context).push(
        //             MaterialPageRoute(builder: (_) => ProgramariPage(cnp: '6090901990011')),
        //           );
        //         },
        //       ),
        //         ListTile(
        //         leading: Icon(Icons.medical_information),
        //         title: Text('Medicatie'),
        //         onTap: () {
        //           Navigator.of(context).push(
        //             MaterialPageRoute(builder: (_) => MedicalFilePage(cnp: '6020220234523')),
        //           );
        //         },
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.notification_important),
        //         title: Text('Istoric alerte'),
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (_) => AlertHistoryPage(cnp: '6090901990011')),
        //           );
        //         },
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.notification_important),
        //         title: Text('Istoric masuratori'),
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (_) => HistoryPage(cnp: '6090901990011')),
        //           );
        //           ListTile(
        //             leading: Icon(Icons.logout),
        //             title: Text('Deconectare'),
        //             onTap: () {
        //               Navigator.of(context).push(
        //                 MaterialPageRoute(builder: (_) => LoginPage()),
        //               );
        //             },
        //           );
        //         },
        //       ),
        //
        //     ],
        //   ),
        // ),
        body: BluetoothHome(
          name: name,
          photoUrl: photoUrl,
          role: role,
          email: email,
          cnp: cnp,
        ),
        ),
    );
  }
}

//pragurile
class PraguriMasuratori {
  final int minPuls ;
  final int maxPuls;
  final int minTemp;
  final int maxTemp;
  final int minEKG;
  final int maxEKG;
  final int minUmiditate;
  final int maxUmiditate;

  PraguriMasuratori({
    required this.minPuls,
    required this.maxPuls,
    required this.minTemp,
    required this.maxTemp,
    required this.minEKG,
    required this.maxEKG,
    required this.minUmiditate,
    required this.maxUmiditate,
  });

  factory PraguriMasuratori.fromJson(Map<String, dynamic> json) {
    return PraguriMasuratori(
      minPuls: json['limita_minima_puls']?? 0,
      maxPuls: json['limita_maxima_puls']?? 200,
      minTemp: json['limita_minima_temperatura'] ?? 30,
      maxTemp: json['limita_maxima_temperatura']?? 45,
      minEKG: json['limita_minima_ekg']?? 0,
      maxEKG: json['limita_maxima_ekg'] ?? 1000,
      minUmiditate: json['limita_minima_umiditate'] ?? 0,
      maxUmiditate: json['limita_maxima_umiditate'] ?? 100,
    );
  }
}

Future<Map<String, dynamic>?> fetchPraguri(String cnp) async {
   try {
     print(Uri.parse("http://192.168.1.18:3000/api/praguriPacient/$cnp"));

     final response = await http.get(Uri.parse("http://192.168.1.18:3000/api/praguriPacient/$cnp"));

    if (response.statusCode == 200) {
      print("📤 Praguri cu succes");
      print(jsonDecode(response.body));
      final data = jsonDecode(response.body);
      final praguriData = data['praguri'];
    return praguriData;
    } else {
      print("❌ Eroare trimitere: ${response.body}");
    }
  } catch (e) {
    return null;
  }
}

class BluetoothHome extends StatefulWidget {
  final String name;
  final String photoUrl;
  final String role;
  final String email;
  final String cnp;

  BluetoothHome({
    required this.name,
    required this.photoUrl,
    required this.role,
    required this.email,
    required this.cnp,
  });

  @override
  _BluetoothHomeState createState() => _BluetoothHomeState();
}

//
// class PraguriDropdownWidget extends StatefulWidget {
//   @override
//   _PraguriDropdownWidgetState createState() => _PraguriDropdownWidgetState();
// }
//
// class _PraguriDropdownWidgetState extends State<PraguriDropdownWidget> {
//   Map<String, dynamic>? praguri;
//   String? selectedPacient;
//   final List<String> pacienti = ['6020220250012', '6010101334455']; // poți extinde lista
//
//   Future<void> fetchAndSetPraguri(String cnp) async {
//     final result = await fetchPraguri(cnp);
//     if (result == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Nu s-au putut prelua pragurile")),
//       );
//       return;
//     }
//
//     setState(() {
//       praguri = result;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         DropdownButton<String>(
//           value: selectedPacient,
//           hint: Text("Selectează un pacient"),
//           items: pacienti.map((cnp) {
//             return DropdownMenuItem(
//               value: cnp,
//               child: Text("Pacient $cnp"),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() => selectedPacient = value);
//             fetchAndSetPraguri(value!);
//           },
//         ),
//         const SizedBox(height: 16),
//         if (praguri != null)
//           Card(
//             elevation: 2,
//             margin: EdgeInsets.symmetric(vertical: 8),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 """
// Puls: ${praguri!['limita_minima_puls']} - ${praguri!['limita_maxima_puls']}
// Temperatură: ${praguri!['limita_minima_temperatura']} - ${praguri!['limita_maxima_temperatura']}
// EKG: ${praguri!['limita_minima_ekg']} - ${praguri!['limita_maxima_ekg']}
// Umiditate: ${praguri!['limita_minima_umiditate']} - ${praguri!['limita_maxima_umiditate']}
//                 """,
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }


// void afiseazaPraguri(BuildContext context) async {
//   final praguri = await fetchPraguri('6020220250012');
//   if (praguri == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Nu s-au putut prelua pragurile")),
//     );
//     return;
//   }
//
//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: Text("Praguri pacient"),
//       content: Text(
//         """
// Puls: ${praguri.minPuls} - ${praguri.maxPuls}
// Temperatură: ${praguri.minTemp} - ${praguri.maxTemp}
// EKG: ${praguri.minEKG} - ${praguri.maxEKG}
// Umiditate: ${praguri.minUmiditate} - ${praguri.maxUmiditate}
//           """,
//       ),
//       actions: [
//         TextButton(
//           child: Text("Închide"),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ],
//     ),
//   );
// }
class _BluetoothHomeState extends State<BluetoothHome> {
  BluetoothDevice? selectedDevice;
  // PraguriMasuratori? praguri;
  Map<String, dynamic>? praguriS;
  BluetoothConnection? connection;
  bool isConnecting = false;
  String receivedData = "";


  void afiseazaPraguri() async {
    print(widget.cnp);
    final praguri = await fetchPraguri(widget.cnp);
    if (praguri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nu s-au putut prelua pragurile")),
      );
      return;
    }
    setState(() {
      praguriS = praguri;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Praguri pacient"),
        content: Text(
          """
Puls: ${praguri['limita_minima_puls']} - ${praguri['limita_maxima_puls']}
Temperatură: ${praguri['limita_minima_temperatura']} - ${praguri['limita_maxima_temperatura']}
EKG: ${praguri['limita_minima_ekg']} - ${praguri['limita_maxima_ekg']}
Umiditate: ${praguri['limita_minima_umiditate']} - ${praguri['limita_maxima_umiditate']}
        """,
        ),
        actions: [
          TextButton(
            child: Text("Închide"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
  void sendMeasurementsToAPI() async {
    final timestamp = DateTime.now().toIso8601String();
    final cnp = widget.cnp;

  final pulse = 60;
      final temperature = 0;
      final umiditate = 20;
      final puls = 60;
      final email = widget.email;

      final data = {
        "cnp": cnp,
        // "cnp_pacient": cnp,
        "masurare_ekg": pulse,
        "masurare_puls": puls,
        "masurare_umiditate": umiditate,
        "masurare_temperatura": temperature,
        "data_masurare": DateTime.now().toIso8601String(),
      };

      //cange
      // final uri = Uri.parse('http://10.0.2.2:3000/api/insert');

      int masurareId=0;
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.18:3000/api/insert'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print(responseData["masurare_id"]);
          print(responseData);
          masurareId = responseData["masurare_id"] ?? 0;
          print(masurareId);
          print("📤 Date trimise cu succes");
        } else {
          print("❌ Eroare trimitere: ${response.statusCode}");
          return;
        }
      } catch (e) {
        print("❌ Exceptie la trimitere: $e");
      }

    // // Simulare date hardcodate
    // final ekg = 800.0;
    // final puls = 120.0;
    // final temperatura = 38.5;
    // final umiditate = 60.0;
    //
    // // 1. Trimite masuratoarea
    // final masurareResponse = await http.post(
    //   Uri.parse('http://10.0.2.2:3000/api/insert1'),
    // headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     "cnp": cnp,
    //     "masurare_ekg": ekg,
    //     "masurare_puls": puls,
    //     "masurare_umiditate": umiditate,
    //     "masurare_temperatura": temperatura,
    //     "data_masurare": timestamp,
    //   }),
    // );

    // 2. Obține pragurile

    // final praguri = await fetchPraguri(cnp);
      print('AICI AR TREBUI' );

    // if (praguri == null) return;

    // 3. Verifică fiecare valoare
    List<Map<String, dynamic>> alerte = [];

    // void verifica(String label, int val, int min, int max) {
    //   if (val < min || val > max) {
    //     alerte.add({
    //       "mesaj": "$label ieșit din limite: $val",
    //       "severitate": (label == "Puls" && val > max) ? "mare" : "medie",
    //     });
    //   }
    // }

    // print('PRGAURI3');
    // print(praguriS);
    // verifica("Puls", puls, praguriS!['limita_minima_puls'], praguriS!['limita_maxima_puls']);
    // verifica("Temperatura", temperature, praguriS!['limita_minima_temperatura'], praguriS!['limita_maxima_temperatura']);
    // verifica("EKG", pulse, praguriS!['limita_minima_ekg'], praguriS!['limita_maxima_ekg']);
    // verifica("Umiditate", umiditate, praguriS!['limita_minima_umiditate'], praguriS!['limita_maxima_umiditate']);

    // verifica("Puls", puls, praguri!.minPuls, praguri!.maxPuls);
    // verifica("Temperatura", temperature, praguri!.minTemp, praguri!.maxTemp);
    // verifica("EKG", pulse, praguri!.minEKG, praguri!.maxEKG);
    // verifica("Umiditate", umiditate, praguri!.minUmiditate, praguri!.maxUmiditate);
print('ALERT');
print(alerte);
    // await Future.delayed(Duration(seconds: 10));
    // // 4. Trimite fiecare alertă în API
    // for (var alert in alerte) {
    //   await http.post(
    //     // Uri.parse("http://10.0.2.2:3000/api/alertaNoua"),
    //     Uri.parse("http://192.168.1.18:3000/api/alertaNoua"),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({
    //       "cnp_pacient": cnp,
    //       "masurare_id": masurareId,
    //       "mesaj": alert["mesaj"],
    //       "severitate": alert["severitate"],
    //       "status": "neprocesata",
    //       "data_generare": timestamp,
    //     }),
    //   );
    // }

    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("Masurători și ${alerte.length} alertă(e) trimise!"),
    //     ),
    //   );
    // }
  }


  //CEL DE AICI E TESTAT SI E OK CU DATE HARDCODATE
  // void sendMeasurementsToAPI() async {
  //   // Simulăm extragerea datelor. În realitate, le parsezi din `receivedData`
  //   final pulse = 105;
  //   final temperature = 374;
  //   final umiditate = 100;
  //   final puls = 920;
  //   final email = widget.email;
  //   final cnp = '6090901990011';
  //   // final cnp = widget.cnp;
  //
  //   final data = {
  //     "cnp": cnp,
  //     // "cnp_pacient": cnp,
  //     "masurare_ekg": pulse,
  //     "masurare_puls": puls,
  //     "masurare_umiditate": umiditate,
  //     "masurare_temperatura": temperature,
  //     "data_masurare": DateTime.now().toIso8601String(),
  //   };
  //
  //   // print(data);
  //   //cange
  //   final uri = Uri.parse('http://10.0.2.2:3000/api/insert1');
  //
  //   try {
  //     final response = await http.post(
  //       uri,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(data),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print("📤 Date trimise cu succes");
  //     } else {
  //       print("❌ Eroare trimitere: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Exceptie la trimitere: $e");
  //   }
  // }




  Widget buildPraguriCard() {
    if (praguriS == null) {
      return Text(''); 
      return Text("🔄 Se încarcă pragurile...");
    }

    return Card(
      color: Colors.blue.shade50,
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("🔧 Praguri măsurători", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Puls: ${praguriS!['limita_minima_puls']} - ${praguriS!['limita_maxima_puls']}"),
            Text("Temperatură: ${praguriS!['limita_minima_temperatura']} - ${praguriS!['limita_maxima_temperatura']}"),
            Text("EKG: ${praguriS!['limita_minima_ekg']} - ${praguriS!['limita_maxima_ekg']}"),
            Text("Umiditate: ${praguriS!['limita_minima_umiditate']} - ${praguriS!['limita_maxima_umiditate']}"),
          ],
            // Text("🔧 Praguri măsurători", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // SizedBox(height: 8),
            // Text("Puls: ${praguri!.minPuls} - ${praguri!.maxPuls}"),
            // Text("Temperatură: ${praguri!.minTemp}°C - ${praguri!.maxTemp}°C"),
            // Text("EKG: ${praguri!.minEKG} - ${praguri!.maxEKG}"),
            // Text("Umiditate: ${praguri!.minUmiditate}% - ${praguri!.maxUmiditate}%"),
          // ],
        ),
      ),
    );
  }
  Future<bool> requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted) {
      return true;
    }
    return false;
  }
  Future<void> fetchSalveazaPraguri() async {
    final rezultat = await fetchPraguri(widget.cnp);
    print('REZ');
    print(rezultat);
    if (rezultat != null) {
      setState(() {
        praguriS = rezultat;
      });
      print("✅ Praguri salvate în state: $praguriS");
    } else {
      print("❌ Nu s-au putut salva pragurile.");
    }
  }
  @override
  void initState() {
    super.initState();
    requestBluetoothPermissions().then((granted) {
      if (granted) {
        FlutterBluetoothSerial.instance.requestEnable();
      } else {
        // Afișează mesaj că permisiunile sunt necesare
        print("Permisiuni Bluetooth refuzate!");
      }
    });
    // FlutterBluetoothSerial.instance.requestEnable();
    // fetchSalveazaPraguri();

    //load praguri
    // fetchPraguri('6020220250012').then((p) {
    //   if (mounted) {
    //     setState(() {
    //       praguri = p;
    //     });
    //   }
    // });

    // Pornește timerul pentru trimiterea datelor la fiecare 10 secunde
    _sendTimer = Timer.periodic(Duration(seconds: 10), (_) {
      sendMeasurementsToAPI();
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() => isConnecting = true);

    try {
      BluetoothConnection newConnection =
      await BluetoothConnection.toAddress(device.address);
      print('✅ Connected to ${device.name}');
      setState(() {
        connection = newConnection;
        selectedDevice = device;
      });

      connection?.input?.listen((Uint8List data) {
        setState(() {
          receivedData += utf8.decode(data);
        });
      });
    } catch (e) {
      print('❌ Eroare la conectare: $e');
      setState(() => connection = null);
    } finally {
      setState(() => isConnecting = false);
    }
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await FlutterBluetoothSerial.instance.getBondedDevices();
  }

  void sendMessage(String message) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(utf8.encode(message + "\n"));
    }
  }

  @override
  void dispose() {
    _sendTimer?.cancel();
    connection?.dispose();
    super.dispose();

  }

  List<Widget> buildDataCards() {
    // Date hardcodate temporar
    final fakeData = [
      "pulse:110",
      "temperature:37.5",
      "umiditate:95",
      "alert:Temperatură crescută"
    ];

    return fakeData.map((line) {
      final parts = line.split(":");
      if (parts.length != 2) return SizedBox.shrink();

      final key = parts[0].trim().toLowerCase();
      final value = parts[1].trim();

      switch (key) {
        case 'pulse':
          final bpm = int.tryParse(value) ?? 0;
          final isHigh = bpm > 100;
          return _buildDataCard(
            label: "Puls",
            value: "$bpm bpm",
            icon: Icons.favorite,
            color: isHigh ? Colors.red : Colors.green,
          );

        case 'temperature':
          final temp = double.tryParse(value) ?? 0;
          return _buildDataCard(
            label: "Temperatură",
            value: "$temp °C",
            icon: Icons.thermostat,
            color: Colors.orange,
          );

        case 'umiditate':
          final umid = double.tryParse(value) ?? 0;
          return _buildDataCard(
            label: "Umiditate",
            value: "$umid",
            icon: Icons.bloodtype,
            color: Colors.blue,
          );
        case 'ekg':
          final ekg = double.tryParse(value) ?? 0;
          return _buildDataCard(
            label: "Ekg",
            value: "$ekg",
            icon: Icons.bloodtype,
            color: Colors.blue,
          );

        case 'alert':
          return Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 10),
                Expanded(child: Text("⚠️ $value")),
              ],
            ),

          );

        default:
          return _buildDataCard(label: key, value: value, icon: Icons.info, color: Colors.grey);
      }
    }).toList();
  }
  //device
  // List<Widget> buildDataCards() {
  //   final lines = receivedData.split("\n").where((line) => line.trim().isNotEmpty);
  //
  //   return lines.map((line) {
  //     final parts = line.split(":");
  //     if (parts.length != 2) return SizedBox.shrink();
  //
  //     final key = parts[0].trim().toLowerCase();
  //     final value = parts[1].trim();
  //
  //     switch (key) {
  //       case 'pulse':
  //         final bpm = int.tryParse(value) ?? 0;
  //         final isHigh = bpm > 100;
  //         return _buildDataCard(
  //           label: "Puls",
  //           value: "$bpm bpm",
  //           icon: Icons.favorite,
  //           color: isHigh ? Colors.red : Colors.green,
  //         );
  //
  //       case 'temperature':
  //         final temp = double.tryParse(value) ?? 0;
  //         return _buildDataCard(
  //           label: "Temperatură",
  //           value: "$temp °C",
  //           icon: Icons.thermostat,
  //           color: Colors.orange,
  //         );
  //
  //       case 'glucose':
  //         final glu = double.tryParse(value) ?? 0;
  //         return _buildDataCard(
  //           label: "Glicemie",
  //           value: "$glu mg/dL",
  //           icon: Icons.bloodtype,
  //           color: Colors.blue,
  //         );
  //
  //       case 'alert':
  //         return Container(
  //           padding: EdgeInsets.all(12),
  //           margin: EdgeInsets.symmetric(vertical: 6),
  //           decoration: BoxDecoration(
  //             color: Colors.red.shade100,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Row(
  //             children: [
  //               Icon(Icons.warning, color: Colors.red),
  //               SizedBox(width: 10),
  //               Expanded(child: Text("⚠️ $value")),
  //             ],
  //           ),
  //         );
  //
  //       default:
  //         return _buildDataCard(label: key, value: value, icon: Icons.info, color: Colors.grey);
  //     }
  //   }).toList();
  // }

  // Widget _buildDataCard({
  //   required String label,
  //   required String value,
  //   required IconData icon,
  //   required Color color,
  // }) {
  //   return Card(
  //     child: ListTile(
  //       leading: Icon(icon, color: color, size: 30),
  //       title: Text(label),
  //       subtitle: Text(
  //         value,
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDataCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(label),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             ...[
              // CircleAvatar(radius: 40, backgroundImage: NetworkImage(widget.photoUrl)),
              // SizedBox(height: 10),
              // Text(widget.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // Text(widget.email, style: TextStyle(color: Colors.grey[600])),
              // Divider(height: 30, thickness: 1),
            ],
            ElevatedButton(
              onPressed: () => afiseazaPraguri(),
              child: Text("Afișează praguri"),
            ),
            ElevatedButton(
              child: Text('🔍 Afișează dispozitive împerecheate'),
              onPressed: () async {
                List<BluetoothDevice> devices = await getBondedDevices();
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: Text("Selectează dispozitiv"),
                    children: devices
                        .map((device) => SimpleDialogOption(
                      child: Text("${device.name} (${device.address})"),
                      onPressed: () {
                        Navigator.pop(context);
                        connectToDevice(device);
                      },
                    ))
                        .toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              selectedDevice == null
                  ? "⚠️ Niciun dispozitiv conectat"
                  : "✅ Conectat la ${selectedDevice!.name}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            buildPraguriCard(),
            if (connection?.isConnected ?? false)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onSubmitted: sendMessage,
                      decoration: InputDecoration(
                        labelText: "Trimite un mesaj",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Text("📨 Date primite:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: buildDataCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
