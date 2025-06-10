// import 'package:flutter/material.dart';
//
// class IngrijitorDashboard extends StatelessWidget {
//   final String email;
//
//   const IngrijitorDashboard({required this.email});
//
//   @override
//   Widget build(BuildContext context) {
//     // Aici poți adăuga o interogare HTTP pentru a obține datele pacientului dacă vrei
//     return Scaffold(
//       backgroundColor: Colors.teal[50],
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.account_circle, size: 100, color: Colors.teal),
//               SizedBox(height: 20),
//               Text("Îngrijitor", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//               SizedBox(height: 12),
//               Text("Pacient asociat:", style: TextStyle(fontSize: 18)),
//               SizedBox(height: 8),
//               Text(email, style: TextStyle(fontSize: 16, color: Colors.black54)),
//               SizedBox(height: 24),
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: const [
//                       Text("Ultimele valori introduse", style: TextStyle(fontWeight: FontWeight.bold)),
//                       SizedBox(height: 8),
//                       Text("Puls: 78 bpm"),
//                       Text("Temperatură: 36.8 °C"),
//                       Text("Glicemie: 110 mg/dL"),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import 'package:flutter/material.dart';
// import 'input.dart'; // asigură-te că ai importul corect
//
// class DashboardPageIngrij extends StatefulWidget {
//   final String email;
//   final String pacientName; // poți primi și alte date dacă ai
//
//   DashboardPageIngrij({required this.email, required this.pacientName});
//
//   @override
//   State<DashboardPageIngrij> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPageIngrij> {
//   // int _selectedIndex = 0;
//   int _selectedIndex = 0;
//
//   Widget _buildContent() {
//     if (_selectedIndex == 0) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Bine ai venit, ${widget.pacientName}',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Email: ${widget.email}',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     return Container(); // Poți adăuga mai multe opțiuni în viitor
//   }
//   void _navigateToInput() {
//     _selectedIndex = 1;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => FormInputPage(
//           email: widget.email,
//           // onSubmit: (hr, temp, glu) async {
//           //   final insertUrl = Uri.parse('http://192.168.1.18:3000/api/insert');
//           //   await http.post(
//           //     insertUrl,
//           //     headers: {'Content-Type': 'application/json'},
//           //     body: json.encode({
//           //       'email': widget.email,
//           //       'puls': hr,
//           //       'temperatura': temp,
//           //       'glicemie': glu,
//           //     }),
//           //   );
//           // },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHomeContent() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           elevation: 6,
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Bine ai venit, ${widget.pacientName}!',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'Email pacient: ${widget.email}',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 SizedBox(height: 32),
//                 ElevatedButton.icon(
//                   onPressed: _navigateToInput,
//                   icon: Icon(Icons.add),
//                   label: Text("Adaugă măsurători"),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _navigateToInput,
//                   icon: Icon(Icons.add),
//                   label: Text("Vizualizare date pacient"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildHomeContent();
//       case 1:
//         _navigateToInput();
//         return SizedBox(); // temporar gol
//       default:
//         return _buildHomeContent();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Panou Ingrijitor"),
//         automaticallyImplyLeading: false,
//       ),
//       body: _buildContent(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() => _selectedIndex = index);
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Acasă'),
//           BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Adaugă'),
//         ],
//       ),
//     );
//   }
// }
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:untitled/screen/dashboard_page.dart';
import 'package:untitled/screen/input.dart';
import 'package:untitled/screen/programari.dart';

import 'aboutIngr.dart';
import 'login.dart';
// import 'programari_page.dart';
// import 'login_page.dart';

class DashboardPageIngrij extends StatelessWidget {
  final String email;
  final  user;
  final String pacientName;
  final String pacientUserName;
  final String pacientRol;
  final String cnpPacient;
  final String cnpIngrijitor;
  final String rolIngrijitor;
  final String rol;
  // final Array $user;

  DashboardPageIngrij({required this.email, required this.pacientName, required this.cnpPacient, required this.cnpIngrijitor, required this.rol, required this.pacientRol, required this.pacientUserName, required this.user,  required this.rolIngrijitor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panou Îngrijitor"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(pacientName),
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
                    builder: (_) => ProgramariPage(cnp: cnpPacient),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Dashboard pacient'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(

                            builder: (_) => BluetoothApp( name:  pacientUserName ?? 'Pacient',
                                photoUrl: 'https://i.pravatar.cc/150?img=1',
                                role: pacientRol,
                                email: email ?? 'DoctorNou@gmail.com',
                                cnp: cnpPacient,
                            user: user,),
                          ),
                        );
                      },
                    ),
            ListTile(
              leading: Icon(Icons.person_4_outlined),
              title: Text('Despre mine'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => IngrijitorProfilePage(

                      email: email ?? 'DoctorNou@gmail.com',
                      nume: user['username'] ?? 'Pacient',
                      cnp: cnpIngrijitor,
                      pacientAsociat: cnpPacient,

                    ),
                  ),
                );
              },
            ),
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bine ai venit, $pacientName',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Email: $email',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Rol: $rol',
                style: TextStyle(fontSize: 16),
              ),
              ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormInputPage(email: email, cnp: cnpPacient,),
                  ),
                );
              },
              child: Text("Adauga masuratori pacient"),
            ),
              ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BluetoothApp( name: pacientName ?? 'Pacient',
                      photoUrl: 'https://i.pravatar.cc/150?img=1',
                      role: 'pacient',
                      email: email ?? 'DoctorNou@gmail.com',
                      cnp: cnpPacient,
                    user: user,),
                  ),
                );
              },
              child: Text("Dashboard Pacient"),
            ),
            //   ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => FormInputPage(email: email),
            //       ),
            //     );
            //   },
            //   child: Text("Vezi istoric pacient"),
            // ),
            ],
          ),
        ),
      ),
    );
  }
}
