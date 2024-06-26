import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front/pages/inicio.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: FormUsuario(),
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
      title: 'Usuario',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FormUsuario(),
    );
  }
}

class FormUsuario extends StatefulWidget {
  @override
  _FormUsuarioState createState() => _FormUsuarioState();
}

class _FormUsuarioState extends State<FormUsuario> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();

  Future<void> _handleSubmit() async {
    String nome = _nomeController.text;
    String email = _emailController.text;
    String senha = _senhaController.text;

    String url = 'http://localhost:3000/usuarios';

    try {
      // Enviar os dados como JSON para o backend
      await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
          // 'id': id
        }),
      );
      print('Dados enviados com sucesso');

      // Após o envio bem-sucedido, navegue para a página de início
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Inicio()),
      );
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
                  'Cadastro de Usuario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Senha',
                  ),
                  obscureText: true,
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
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}

class ListaUsuarios extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aqui você pode implementar a lista de usuários
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuários'),
      ),
      body: Center(
        child: Text('Lista de Usuários'),
      ),
    );
  }
}
