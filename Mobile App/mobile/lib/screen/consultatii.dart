import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConsultatiePage extends StatefulWidget {
  final int idProgramare;

  ConsultatiePage({required this.idProgramare});

  @override
  _ConsultatiePageState createState() => _ConsultatiePageState();
}

class _ConsultatiePageState extends State<ConsultatiePage> {
  Map<String, dynamic>? consultatie;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchConsultatie();
  }

  Future<void> fetchConsultatie() async {
    final url = Uri.parse('http://192.168.1.18:3000/api/programari/${widget.idProgramare}/consultatie');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        consultatie = json.decode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalii consultație")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : consultatie == null
          ? Center(child: Text("Nu există detalii pentru această consultație."))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Diagnostic: ${consultatie!['diagnostic']}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Tratament: ${consultatie!['tratament']}"),
            SizedBox(height: 8),
            Text("Recomandări: ${consultatie!['recomandari']}"),
            SizedBox(height: 8),
            Text("Observații: ${consultatie!['observatii']}"),
            SizedBox(height: 8),
            Text("Data consultației: ${consultatie!['data_consultatie']}"),
          ],
        ),
      ),
    );
  }
}
