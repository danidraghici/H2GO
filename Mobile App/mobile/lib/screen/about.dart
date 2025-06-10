import 'package:flutter/material.dart';

class PacientProfilePage extends StatelessWidget {
  final String nume;
  final String email;
  final String cnp;
  final String telefon;
  final String adresa;
  final String dataNasterii;
  final String sex;
  final String medicCurant;

  const PacientProfilePage({
    required this.nume,
    required this.email,
    required this.cnp,
    required this.telefon,
    required this.adresa,
    required this.dataNasterii,
    required this.sex,
    required this.medicCurant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil pacient')),
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
                Center(child: Icon(Icons.account_circle, size: 80, color: Colors.teal)),
                SizedBox(height: 20),
                _info("👤 Nume", nume),
                _info("📧 Email", email),
                _info("🆔 CNP", cnp),
                _info("📞 Telefon", telefon),
                _info("🏡 Adresă", adresa),
                _info("🎂 Data nașterii", dataNasterii),
                _info("⚧️ Sex", sex),
                _info("🩺 Medic curant", medicCurant),
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
