import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final String cnp;

  HistoryPage({required this.cnp});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, dynamic> masuratori = {};
  bool loading = true;
  final formatter = DateFormat('dd.MM.yyyy HH:mm:ss');
  @override
  void initState() {
    super.initState();
    fetchMasuratori();
  }

  Future<void> fetchMasuratori() async {
    // final url = Uri.parse('http://10.0.2.2:3000/api/masuratori/6090901990011');
    final url = Uri.parse('http://192.168.1.18:3000/api/masuratori/${widget.cnp}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          masuratori = jsonDecode(response.body);
          loading = false;
        });
      }
    } catch (e) {
      print("❌ Eroare la fetch masuratori: $e");
    }
  }

  List<FlSpot> convertEKGToSpots() {
    final List ekgValues = masuratori['ekg'] ?? [];
    return ekgValues.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), (entry.value as num).toDouble());
    }).toList();
  }

  Widget buildEKGGraph() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          SizedBox(height: 10),
          Text('📊 EKG - Ultimele 100 valori', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(LineChartData(
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: convertEKGToSpots(),
                    isCurved: false,
                    barWidth: 2,
                    // colors: [Colors.purple],
                    dotData: FlDotData(show: false),
                  )
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(String label, dynamic value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        subtitle: Text(value.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Istoric Măsurători')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildInfoCard("🫀 Puls", masuratori['puls'], Icons.favorite, Colors.red),
          buildInfoCard("🌡️ Temperatură", masuratori['temperatura'], Icons.thermostat, Colors.orange),
          buildInfoCard("💧 Umiditate", masuratori['umiditate'], Icons.water, Colors.blue),
          buildInfoCard("📅 Ultima măsurare",  formatter.format(DateTime.parse(masuratori['data_masurare']).toLocal()), Icons.calendar_today, Colors.grey),
          buildEKGGraph(),
        ],
      ),
    );
  }
}
