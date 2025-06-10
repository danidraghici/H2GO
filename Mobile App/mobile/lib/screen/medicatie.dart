import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicalFilePage extends StatefulWidget {
  final String cnp;

  MedicalFilePage({required this.cnp});

  @override
  State<MedicalFilePage> createState() => _MedicalFilePageState();
}

class _MedicalFilePageState extends State<MedicalFilePage> {
  List<dynamic> medicatieCurenta = [];
  List<dynamic> alergeni = [];
  List<dynamic> istoric = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMedicalData();
  }

  Future<void> fetchMedicalData() async {
    final uriBase = 'http://192.168.1.18:3000/api';
    // final uriBase = 'http://10.0.2.2:3000/api';

    try {
      final m1 = await http.get(Uri.parse('$uriBase/medicatie_curenta/${widget.cnp}'));
      // final m1 = await http.get(Uri.parse('$uriBase/medicatie_curenta/${widget.cnp}'));
      // final m2 = await http.get(Uri.parse('$uriBase/alergeni/${widget.cnp}'));
      final m2 = await http.get(Uri.parse('$uriBase/alergeni/${widget.cnp}'));
      final m3 = await http.get(Uri.parse('$uriBase/istoric_medicatie/${widget.cnp}'));

      if (m1.statusCode == 200 && m2.statusCode == 200 && m3.statusCode == 200) {
        setState(() {
          medicatieCurenta = jsonDecode(m1.body);
          alergeni = jsonDecode(m2.body);
          istoric = jsonDecode(m3.body);
          loading = false;
        });
      }
    } catch (e) {
      print('❌ Eroare la fetch: $e');
    }
  }

  Widget buildSection(String title, List<Widget> items) {
    return ExpansionTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fișă medicală")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildSection("💊Medicație curentă", medicatieCurenta.map((med) {
            return ListTile(
              title: Text(med['denumire_medicament']),
              subtitle: Text(
                  '${med['forma_farmaceutica']} • ${med['posologie']}'),
              trailing: Text('📅 ${med['data_incepere']}'),
            );
          }).toList()),

          buildSection("⚠️ Alergeni", alergeni.map((a) {
            return ListTile(
              title: Text(a['substanta']),
              subtitle: Text('Status: ${a['status']}'),
              trailing: Text('📅 ${a['data_inregistrare']}'),
            );
          }).toList()),

          buildSection("📄 Istoric medicație", istoric.map((hist) {
            return ListTile(
              title: Text(hist['denumire_medicament']),
              subtitle: Text(
                  '${hist['forma_farmaceutica']} • ${hist['posologie']}'),
              trailing: Text('⏳ ${hist['data_incepere']} → ${hist['data_finalizare'] ?? 'nedefinit'}'),
            );
          }).toList()),
        ],
      ),
    );
  }
}
