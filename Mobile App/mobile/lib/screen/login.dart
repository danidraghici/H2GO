import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_page.dart';
import 'ingrijitorDash.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);

    try {
      final url = Uri.parse('http://192.168.1.18:3000/api/login/mobile');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];
        final role = user['rol'];
        print('ROLE');
        final cnpIngrijitor = user['cnp_ingrijitor'];
        final cnpPacientIngrij = user['cnp_pacient'];
        final cnpPacient = user['CNP'];
        final rolIngrijitor = user['rol_ingrijitor'];
        final pacientUserName = user['username'];
        print(user);
        print('USER');
        if (role == 'pacient') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BluetoothApp(
                name: user['username'] ?? 'Pacient',
                photoUrl: 'https://i.pravatar.cc/150?img=1',
                role: role,
                email: user['email'] ?? 'DoctorNou@gmail.com',
                cnp: cnpPacient,
                user: user,
              ),
            ),
          );
        } else if (role == 'ingrijitor') {
          print('HERE IN INGR');
          print(user['email']);
          print(cnpIngrijitor);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPageIngrij(
                email: user['email'] ?? 'DoctorNou@gmail.com',
                user: user,
                pacientName: 'ingrijitor01',
                cnpPacient: cnpPacientIngrij,
                cnpIngrijitor: cnpIngrijitor,
                  rol: rolIngrijitor,
                pacientRol: role,
                pacientUserName: pacientUserName,
                rolIngrijitor: rolIngrijitor,

                // onSubmit: (hr, temp, glu) async {
                //   final insertUrl = Uri.parse('http://192.168.1.18:3000/api/masuratori');
                //   await http.post(
                //     insertUrl,
                //     headers: {'Content-Type': 'application/json'},
                //     body: json.encode({
                //       'email': user['email'],
                //       'puls': hr,
                //       'temperatura': temp,
                //       'glicemie': glu,
                //     }),
                //   );
                // },
              ),

                    // builder: (context) => CaregiverHomePage(email: user['email']),
                  // ),
                // );
            ),
          );
        } else {
          setState(() => _message = 'Acces interzis pentru rolul: $role');
        }
      } else {
        final error = json.decode(response.body);
        setState(() => _message = error['message'] ?? 'Eroare necunoscută');
      }
    } catch (e) {
      setState(() => _message = 'Eroare de conexiune');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Icon(Icons.medical_services, size: 100, color: Colors.teal),
              SizedBox(height: 16),
              Text("H2GO", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Parolă", border: OutlineInputBorder()),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Autentificare"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
              ),
              SizedBox(height: 16),
              Text(_message, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
