import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'consultatii.dart';

class ProgramariPage extends StatefulWidget {
  final String cnp;

  ProgramariPage({required this.cnp});

  @override
  _ProgramariPageState createState() => _ProgramariPageState();
}

class _ProgramariPageState extends State<ProgramariPage> {
  List<dynamic> programari = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProgramari();
  }

  Future<void> fetchProgramari() async {
    print(widget.cnp);
    final url = Uri.parse('http://192.168.1.18:3000/api/programariPerPacient/${widget.cnp}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        programari = data;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Programările Mele")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: programari.length,
        itemBuilder: (context, index) {
          final prog = programari[index];
          final data = DateTime.parse(prog['data_programare']);
          final esteViitoare = data.isAfter(DateTime.now());

          return ListTile(
            title: Text("${data.toLocal()}"),
            subtitle: Text("Status: ${prog['status']}, "
                "Comentarii : ${prog['comentarii']}"),
            trailing: esteViitoare ? Icon(Icons.schedule) : Icon(Icons.history),
            onTap: () {
              if (prog['id_consultatie'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConsultatiePage(idProgramare: prog['id']),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
