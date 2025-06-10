import 'package:flutter/material.dart';
import 'package:untitled/screen/input.dart';
// import 'form_input_page.dart';
import 'ingrijitorDash.dart'; // ai deja asta

class CaregiverHomePage extends StatefulWidget {
  final String email;
  final String cnp;

  const CaregiverHomePage({required this.email, required this.cnp});

  @override
  _CaregiverHomePageState createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      // IngrijitorDashboard(email: widget.email),
      FormInputPage(
        email: widget.email,
        cnp: widget.cnp,
        // onSubmit: (hr, temp, glu) {
        //   // poți face refresh sau altceva aici
        // },
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Pacient"),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Formular"),
        ],
      ),
    );
  }
}
