import 'dart:convert';
import 'package:front/pages/form-usuario.dart';
import 'package:front/pages/form-atividade.dart';
import 'package:front/pages/inicio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: ListaAtividades(),
  ));
}

class ListaAtividades extends StatefulWidget {
  @override
  _ListaAtividadesState createState() => _ListaAtividadesState();
}

class _ListaAtividadesState extends State<ListaAtividades> {
  late Future<List<Atividade>> _futureAtividades;

  @override
  void initState() {
    super.initState();
    _futureAtividades = _fetchAtividades();
  }

  Future<List<Atividade>> _fetchAtividades() async {
    final response = await http.get(Uri.parse('http://localhost:3000/atividades'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((atividade) => Atividade.fromJson(atividade)).toList().cast<Atividade>();
    } else {
      throw Exception('Failed to load atividades');
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Lista de Atividades'),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FormAtividade()),
            );
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
          child: FutureBuilder<List<Atividade>>(
            future: _futureAtividades,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('Nenhuma atividade encontrada'));
              } else {
                return DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Título')),
                    DataColumn(label: Text('Data')),
                    DataColumn(label: Text('Operações')),
                  ],
                  rows: snapshot.data!.map((atividade) {
                    return DataRow(cells: [
                      DataCell(Text(atividade.id.toString())),
                      DataCell(Container(
                        width: 200, // ajuste a largura conforme necessário
                        child: Text(atividade.titulo),
                      )),
                      DataCell(Text(atividade.data)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditAtividadeDialog(atividade);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteAtividade(atividade);
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


  void _deleteAtividade(Atividade atividade) async {
  // Mostrar um diálogo de confirmação
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Tem certeza de que deseja excluir a atividade ${atividade.titulo}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirmar'),
          ),
        ],
      );
    },
  );

  // Se o atividade confirmou a exclusão, enviar a requisição DELETE
  if (confirmDelete == true) {
    await _sendDeleteRequest(atividade.id);
  }
}

Future<void> _sendDeleteRequest(int atividadeId) async {
  String url = 'http://localhost:3000/atividades/$atividadeId'; // URL para excluir o atividade com o ID específico
  
  try {
    await http.delete(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );
    print('Atividade excluída com sucesso');
  } catch (error) {
    print('Erro ao excluir atividade: $error');
  }
}


  void _showEditAtividadeDialog(Atividade atividade) async {
    TextEditingController tituloController = TextEditingController(text: atividade.titulo);
    TextEditingController descController = TextEditingController(text: atividade.desc);
    TextEditingController dataController = TextEditingController(text: atividade.data);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Atividade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
               TextField(
                controller: dataController,
                decoration: InputDecoration(labelText: 'Senha'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _updateAtividade(atividade.id, tituloController.text, descController.text, dataController.text);
                Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Inicio()),
                        );
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _updateAtividade(int atividadeId, String newName, String newEmail, String newSenha) async {
  String url = 'http://localhost:3000/atividades/$atividadeId';
  
  try {
    await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'titulo': newName,
        'desc': newEmail,
        'data': newSenha,
        'id': atividadeId,
      }),
    );
    print('Atividade atualizado com sucesso');
  } catch (error) {
    print('Erro ao atualizar atividade: $error');
  }
}
}

class Atividade {
  final int id;
  final String titulo;
  final String desc;
  final String data;

  Atividade({required this.id, required this.titulo, required this.desc, required this.data});

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      titulo: json['titulo'],
      desc: json['desc'],
      data: json['data'],
    );
  }
}
