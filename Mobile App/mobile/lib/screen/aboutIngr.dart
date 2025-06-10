import 'package:flutter/material.dart';

class IngrijitorProfilePage extends StatelessWidget {
  final String nume;
  final String email;
  final String cnp;
  final String pacientAsociat;

  const IngrijitorProfilePage({
    required this.nume,
    required this.email,
    required this.cnp,
    required this.pacientAsociat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil îngrijitor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Icon(Icons.person_outline, size: 80, color: Colors.blue)),
                SizedBox(height: 20),
                _info("👤 Nume", nume),
                _info("📧 Email", email),
                _info("🆔 CNP", cnp),
                _info("🧑‍🤝‍🧑 CNP Pacient îngrijit", pacientAsociat),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
