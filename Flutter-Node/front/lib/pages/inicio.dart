// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:front/pages/lista-usuario-atividades.dart';
import 'package:front/pages/lista-usuarios.dart';
import 'package:front/pages/lista-atividades.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inicio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Inicio(),
    );
  }
}

class Inicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaUsuarios()),
                );
              },
              child: Text('Usuários'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaAtividades()),
                );
              },
              child: Text('Atividades'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaUsuarioAtividades()),
                );
              },
              child: Text('Atividades de usuário'),
            ),
          ],
        ),
      ),
    );
  }
}
