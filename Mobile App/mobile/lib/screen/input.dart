// // import 'package:flutter/material.dart';
// //
// // class FormInputPage extends StatefulWidget {
// //   final Function(int hr, double temp, double glu) onSubmit;
// //
// //   FormInputPage({required this.onSubmit});
// //
// //   @override
// //   _FormInputPageState createState() => _FormInputPageState();
// // }
// //
// // class _FormInputPageState extends State<FormInputPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _hrController = TextEditingController();
// //   final _tempController = TextEditingController();
// //   final _gluController = TextEditingController();
// //
// //   void _submit() {
// //     if (_formKey.currentState!.validate()) {
// //       final hr = int.parse(_hrController.text);
// //       final temp = double.parse(_tempController.text);
// //       final glu = double.parse(_gluController.text);
// //
// //       widget.onSubmit(hr, temp, glu);
// //       Navigator.pop(context);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Introducere manuală")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Form(
// //           key: _formKey,
// //           child: Column(
// //             children: [
// //               TextFormField(
// //                 controller: _hrController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: InputDecoration(labelText: "Puls (bpm)"),
// //                 validator: (val) => val!.isEmpty ? "Completează pulsul" : null,
// //               ),
// //               SizedBox(height: 16),
// //               TextFormField(
// //                 controller: _tempController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: InputDecoration(labelText: "Temperatură (°C)"),
// //                 validator: (val) => val!.isEmpty ? "Completează temperatura" : null,
// //               ),
// //               SizedBox(height: 16),
// //               TextFormField(
// //                 controller: _gluController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: InputDecoration(labelText: "Glicemie (mg/dL)"),
// //                 validator: (val) => val!.isEmpty ? "Completează glicemia" : null,
// //               ),
// //               SizedBox(height: 32),
// //               ElevatedButton(
// //                 onPressed: _submit,
// //                 child: Text("Trimite"),
// //               )
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //===========================
// // input.dart
// // //===========================
// // import 'package:flutter/material.dart';
// //
// // class FormInputPage extends StatefulWidget {
// //   final Function(int hr, double temp, double glu) onSubmit;
// //   final String email;
// //
// //   FormInputPage({required this.onSubmit, required this.email});
// //
// //   @override
// //   _FormInputPageState createState() => _FormInputPageState();
// // }
// //
// // class _FormInputPageState extends State<FormInputPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _hrController = TextEditingController();
// //   final _tempController = TextEditingController();
// //   final _gluController = TextEditingController();
// //
// //   void _submit() {
// //     if (_formKey.currentState!.validate()) {
// //       final hr = int.parse(_hrController.text);
// //       final temp = double.parse(_tempController.text);
// //       final glu = double.parse(_gluController.text);
// //
// //       widget.onSubmit(hr, temp, glu);
// //       Navigator.pop(context);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Introducere manuală")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Form(
// //           key: _formKey,
// //           child: Column(
// //             children: [
// //               TextFormField(
// //                 controller: _hrController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: InputDecoration(labelText: "Puls (bpm)"),
// //                 validator: (val) => val!.isEmpty ? "Completează pulsul" : null,
// //               ),
// //               SizedBox(height: 16),
// //               TextFormField(
// //                 controller: _tempController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: InputDecoration(labelText: "Temperatură (°C)"),
// //                 validator: (val) => val!.isEmpty ? "Completează temperatura" : null,
// //               ),
// //               SizedBox(height: 16),
// //               TextFormField(
// //                 controller: _gluController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: InputDecoration(labelText: "Glicemie (mg/dL)"),
// //                 validator: (val) => val!.isEmpty ? "Completează glicemia" : null,
// //               ),
// //               SizedBox(height: 32),
// //               ElevatedButton(
// //                 onPressed: _submit,
// //                 child: Text("Trimite"),
// //               )
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
// //===========================
// // input.dart
// //===========================
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class FormInputPage extends StatefulWidget {
//   final Function(int hr, double temp, double glu) onSubmit;
//   final String email;
//
//   FormInputPage({required this.onSubmit, required this.email});
//
//   @override
//   _FormInputPageState createState() => _FormInputPageState();
// }
//
// class _FormInputPageState extends State<FormInputPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _hrController = TextEditingController();
//   final _tempController = TextEditingController();
//   final _gluController = TextEditingController();
//
//   void _submit() async {
//     if (_formKey.currentState!.validate()) {
//       final hr = int.parse(_hrController.text);
//       final temp = double.parse(_tempController.text);
//       final glu = double.parse(_gluController.text);
//
//       try {
//         final response = await http.post(
//           Uri.parse('http://10.0.2.2:3000/api/insert'),
//           headers: {'Content-Type': 'application/json'},
//           body: json.encode({
//             'email': widget.email,
//             'puls': hr,
//             'temperatura': temp,
//             'glicemie': glu,
//           }),
//         );
//
//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Datele au fost trimise cu succes')),
//           );
//           widget.onSubmit(hr, temp, glu);
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Eroare la salvare: ${response.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Eroare la conectare: $e')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Introducere manuală")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _hrController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: "Puls (bpm)"),
//                 validator: (val) => val!.isEmpty ? "Completează pulsul" : null,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _tempController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: "Temperatură (°C)"),
//                 validator: (val) => val!.isEmpty ? "Completează temperatura" : null,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _gluController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: "Glicemie (mg/dL)"),
//                 validator: (val) => val!.isEmpty ? "Completează glicemia" : null,
//               ),
//               SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: _submit,
//                 child: Text("Trimite"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormInputPage extends StatefulWidget {
  // final Function(int hr, double temp, double glu) onSubmit;
  final String email;
  final String cnp;

  FormInputPage({ required this.email, required this.cnp});

  @override
  _FormInputPageState createState() => _FormInputPageState();
}

class _FormInputPageState extends State<FormInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _pulsController = TextEditingController();
  final _tempController = TextEditingController();
  final _umiditateController = TextEditingController();


  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final puls = int.parse(_pulsController.text);
      final temperature = double.parse(_tempController.text);
      final umiditate = double.parse(_umiditateController.text);

      final timestamp = DateTime.now().toIso8601String();
      final cnp = '6090901990011';

      final pulse = 44;
      // final cnp = widget.cnp;

      final data = {
        "cnp": cnp,
        "masurare_ekg": pulse,
        "masurare_puls": puls,
        "masurare_umiditate": umiditate,
        "masurare_temperatura": temperature,
        "data_masurare": DateTime.now().toIso8601String(),
      };
      int masurareId = 0;
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.18:3000/api/insert'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print(responseData["masurare_id"]);
          print(responseData);
          masurareId = responseData["masurare_id"] ?? 0;
          print(masurareId);
          print("📤 Date trimise cu succes");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Succes"),
                  content: Text("Datele au fost trimise cu succes."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigator.of(context).pop();
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              }
          );
        } else {
          print("❌ Eroare trimitere: ${response.statusCode}");
          return;
        }
      } catch (e) {
        print("❌ Exceptie la trimitere: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Introducere manuală")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pulsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Puls (bpm)"),
                validator: (val) => val!.isEmpty ? "Completează pulsul" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tempController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Temperatură (°C)"),
                validator: (val) => val!.isEmpty ? "Completează temperatura" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _umiditateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Umiditate"),
                validator: (val) => val!.isEmpty ? "Completează glicemia" : null,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: Text("Trimite"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

