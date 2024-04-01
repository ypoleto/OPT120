import 'package:flutter/material.dart';
import 'package:front/pages/form-usuario.dart';
import 'package:front/pages/form-atividade.dart';
import 'package:front/pages/form-usuario-atividade.dart';
import 'package:front/pages/inicio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projeto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Inicio(),
        '/usuario': (context) => FormUsuario(),
        '/atividade': (context) => FormAtividade(),
        '/usuario-atividade': (context) => FormUsuarioAtividade(),
      },
    );
  }
}
