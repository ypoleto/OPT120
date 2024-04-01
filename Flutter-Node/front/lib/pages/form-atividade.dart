// ignore_for_file: prefer_const_constructors, avoid_print, prefer_final_fields, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front/pages/inicio.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: FormAtividade(),
  ));
}

int idGenerator() {
  final now = DateTime.now();
  return now.microsecondsSinceEpoch;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atividade',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FormAtividade(),
    );
  }
}

class FormAtividade extends StatefulWidget {
  @override
  _FormAtividadeState createState() => _FormAtividadeState();
}

class _FormAtividadeState extends State<FormAtividade> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _dataController = TextEditingController();

  Future<void> _handleSubmit() async {
    String titulo = _tituloController.text;
    String desc = _descController.text;
    String data = (_dataController.text);

    String url = 'http://localhost:3000/atividades';

    try {
      await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'titulo': titulo,
          'desc': desc,
          'data': (data),
        }),
      );
      print('Dados enviados com sucesso');
    } catch (error) {
      print('Erro ao enviar os dados: $error');
    }

    print('titulo: $titulo (${titulo.runtimeType})');
    print('desc: $desc (${desc.runtimeType})');
    print('data: $data (${data.runtimeType})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(100.0),
          child: Padding(
            padding: EdgeInsets.all(26.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cadastro de Atividade',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Titulo',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Descricao',
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _dataController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Data (ano-mes-dia)',
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Enviar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Inicio()),
                        );
                      },
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    _dataController.dispose();
    super.dispose();
  }
}
