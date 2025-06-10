import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AlertHistoryPage extends StatefulWidget {
  final String cnp;

  AlertHistoryPage({required this.cnp});

  @override
  State<AlertHistoryPage> createState() => _AlertHistoryPageState();
}

class _AlertHistoryPageState extends State<AlertHistoryPage> {
  List<dynamic> alerte = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAlerte();
  }

  Future<void> fetchAlerte() async {
    final url = Uri.parse('http://192.168.1.18:3000/api/alerte/${widget.cnp}');
    // final url = Uri.parse('http://10.0.2.2:3000/api/alerte/6090901990011');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          alerte = jsonDecode(response.body);
          loading = false;
        });
      }
    } catch (e) {
      print("❌ Eroare la fetch alerte: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Istoric alerte")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: alerte.length,
        itemBuilder: (context, index) {
          final alerta = alerte[index];
          return ListTile(
            leading: Icon(Icons.warning, color: alerta['severitate'] == 'mare' ? Colors.red : Colors.orange),
            title: Text(alerta['mesaj']),
            subtitle: Text("Severitate: ${alerta['severitate']}"),
            trailing: Text(alerta['data_generare'].toString().substring(0, 16)),
          );
        },
      ),
    );
  }
}
