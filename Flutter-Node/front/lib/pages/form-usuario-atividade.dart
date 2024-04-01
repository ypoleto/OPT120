// ignore_for_file: prefer_const_constructors, avoid_print, prefer_final_fields, library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front/pages/inicio.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: FormUsuarioAtividade(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atividade',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FormUsuarioAtividade(),
    );
  }
}

class FormUsuarioAtividade extends StatefulWidget {
  @override
  _FormUsuarioAtividadeState createState() => _FormUsuarioAtividadeState();
}

class _FormUsuarioAtividadeState extends State<FormUsuarioAtividade> {
  TextEditingController _dataController = TextEditingController();
  TextEditingController _notaController = TextEditingController();
  int? _selectedUsuarioId;
  int? _selectedAtividadeId;
  Future<List<Usuario>>? _usersFuture;
  Future<List<Atividade>>? _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsuarios();
    _activitiesFuture = _fetchAtividades();
  }

  Future<List<Usuario>> _fetchUsuarios() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/usuarios'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((usuario) => Usuario.fromJson(usuario))
          .toList()
          .cast<Usuario>();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<Atividade>> _fetchAtividades() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/atividades'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((atividade) => Atividade.fromJson(atividade))
          .toList()
          .cast<Atividade>();
    } else {
      throw Exception('Failed to load activities');
    }
  }

  Future<void> _handleSubmit() async {
    String data = _dataController.text;
    String nota = _notaController.text;
    String url = 'http://localhost:3000/usuario-atividades';

    try {
      await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'usuario_id': _selectedUsuarioId,
          'atividade_id': _selectedAtividadeId,
          'entrega': data,
          'nota': double.parse(nota),
        }),
      );
      print('Dados enviados com sucesso');
    } catch (error) {
      print('Erro ao enviar os dados: $error');
    }
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
                  'Cadastro de Atividade de Usuário',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildUsuarioSelector(),
                SizedBox(height: 20),
                _buildAtividadeSelector(),
                SizedBox(height: 20),
                TextFormField(
                  controller: _dataController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Data (ano-mes-dia)',
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _notaController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nota',
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text('Enviar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Inicio()),
                        );
                      },
                      child: Text('Voltar'),
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

  Widget _buildUsuarioSelector() {
    return FutureBuilder<List<Usuario>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Text('Nenhum usuário encontrado');
        } else {
          return DropdownButtonFormField<int>(
            value: _selectedUsuarioId,
            onChanged: (int? newValue) {
              setState(() {
                _selectedUsuarioId = newValue;
              });
            },
            items: snapshot.data!.map<DropdownMenuItem<int>>((user) {
              return DropdownMenuItem<int>(
                value: user.id,
                child: Text(user.nome),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Usuário',
              border: OutlineInputBorder(),
            ),
          );
        }
      },
    );
  }

  Widget _buildAtividadeSelector() {
    return FutureBuilder<List<Atividade>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Text('Nenhuma atividade encontrada');
        } else {
          return DropdownButtonFormField<int>(
            value: _selectedAtividadeId,
            onChanged: (int? newValue) {
              setState(() {
                _selectedAtividadeId = newValue;
              });
            },
            items: snapshot.data!.map<DropdownMenuItem<int>>((activity) {
              return DropdownMenuItem<int>(
                value: activity.id,
                child: Text(activity.titulo),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Atividade',
              border: OutlineInputBorder(),
            ),
          );
        }
      },
    );
  }
}

class Usuario {
  final int id;
  final String nome;

  Usuario({required this.id, required this.nome});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
    );
  }
}

class Atividade {
  final int id;
  final String titulo;

  Atividade({required this.id, required this.titulo});

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      titulo: json['titulo'],
    );
  }
}
