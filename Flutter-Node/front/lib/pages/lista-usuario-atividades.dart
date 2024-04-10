import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    home: ListaUsuarioAtividades(),
  ));
}

class ListaUsuarioAtividades extends StatefulWidget {
  @override
  _ListaUsuarioAtividadesState createState() => _ListaUsuarioAtividadesState();
}

class _ListaUsuarioAtividadesState extends State<ListaUsuarioAtividades> {
  late Future<List<UserAtividade>> _futureUserAtividades;

  @override
  void initState() {
    super.initState();
    _futureUserAtividades = _fetchUserAtividades();
  }

  String _formatDeliveryDate(String deliveryDate) {
    DateTime dateTime = DateTime.parse(deliveryDate);
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    return formattedDate;
  }

  Future<List<UserAtividade>> _fetchUserAtividades() async {
    final response = await http.get(Uri.parse('http://localhost:3000/usuario-atividades'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((useratividade) => UserAtividade.fromJson(useratividade)).toList().cast<UserAtividade>();
    } else {
      throw Exception('Failed to load useratividades');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuários e suas atividades'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Implemente a navegação para a tela de adicionar usuário-atividade
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50.0),
          child: SizedBox(
            width: double.infinity,
            child: FutureBuilder<List<UserAtividade>>(
              future: _futureUserAtividades,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhum usuário encontrado'));
                } else {
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Usuário')),
                      DataColumn(label: Text('Atividade')),
                      DataColumn(label: Text('Nota')),
                      DataColumn(label: Text('Entrega')),
                      DataColumn(label: Text('Operações')),
                    ],
                    rows: snapshot.data!.map((useratividade) {
                      String entregaFormatted = _formatDeliveryDate(useratividade.entrega);
                      return DataRow(cells: [
                        DataCell(Text(useratividade.id.toString())),
                        DataCell(Text(useratividade.usuarioNome)), // Mostra o nome do usuário
                        DataCell(Text(useratividade.atividadeTitulo)), // Mostra o título da atividade
                        DataCell(Text(useratividade.nota.toString())),
                        DataCell(Text(entregaFormatted)),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Implemente a função de editar
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Implemente a função de deletar
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class UserAtividade {
  final int id;
  final String usuarioNome; // Adiciona o nome do usuário
  final String atividadeTitulo; // Adiciona o título da atividade
  final int nota;
  final String entrega;

  UserAtividade({
    required this.id,
    required this.usuarioNome,
    required this.atividadeTitulo,
    required this.nota,
    required this.entrega,
  });

  factory UserAtividade.fromJson(Map<String, dynamic> json) {
    return UserAtividade(
      id: json['usuario_atividade_id'], // Altera para o ID correto
      usuarioNome: json['usuario_nome'], // Adiciona o nome do usuário
      atividadeTitulo: json['atividade_titulo'], // Adiciona o título da atividade
      nota: json['nota'] ?? 0,
      entrega: json['entrega'],
    );
  }
}
