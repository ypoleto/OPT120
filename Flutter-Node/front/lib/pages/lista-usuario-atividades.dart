import 'dart:convert';
import 'package:front/pages/form-usuario-atividade.dart';
import 'package:front/pages/inicio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  late Future<List<dynamic>> _futureUsuarios;
  late Future<List<dynamic>> _futureAtividades;

  @override
  void initState() {
    super.initState();
    _futureUserAtividades = _fetchUserAtividades();
    _futureUsuarios = _fetchUsuarios();
    _futureAtividades = _fetchAtividades();
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

  Future<List<dynamic>> _fetchUsuarios() async {
    final response = await http.get(Uri.parse('http://localhost:3000/usuarios'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load usuarios');
    }
  }

  Future<List<dynamic>> _fetchAtividades() async {
    final response = await http.get(Uri.parse('http://localhost:3000/atividades'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load atividades');
    }
  }

  Future<String> getUsuarioAtividadeText(int usuario_id, int atividade_id) async {
    // Obtendo a lista de usuários e atividades
    List<dynamic> usuarios = await _futureUsuarios;
    List<dynamic> atividades = await _futureAtividades;

    // Procurando pelo usuário com o id correspondente
    dynamic usuario = usuarios.firstWhere((usuario) => usuario['id'] == usuario_id, orElse: () => null);

    // Procurando pela atividade com o id correspondente
    dynamic atividade = atividades.firstWhere((atividade) => atividade['id'] == atividade_id, orElse: () => null);

    // Verificando se o usuário e a atividade foram encontrados
    if (usuario != null && atividade != null) {
      // Construindo a string com o nome do usuário e o título da atividade
      String usuarioNome = usuario['nome'];
      String atividadeTitulo = atividade['titulo'];
      return '$usuarioNome - $atividadeTitulo';
    } else {
      return 'Usuário ou atividade não encontrados';
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
            Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormUsuarioAtividade()),
            );
          },
        ),
      ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.8, // 80% da altura da tela
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
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  UserAtividade useratividade = snapshot.data![index];
                  return FutureBuilder<String>(
                    future: getUsuarioAtividadeText(useratividade.usuario_id, useratividade.atividade_id),
                    builder: (context, textSnapshot) {
                      if (textSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Carregando...'),
                        );
                      } else if (textSnapshot.hasError) {
                        return ListTile(
                          title: Text('Erro: ${textSnapshot.error}'),
                        );
                      } else {
                        return ListTile(
                          title: Text(textSnapshot.data!), // Aqui estamos usando o valor resolvido da Future<String>
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditUserAtividadeDialog(useratividade);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteUserAtividade(useratividade);
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _deleteUserAtividade(UserAtividade useratividade) async {
    // Mostrar um diálogo de confirmação
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza de que deseja excluir o usuário-atividade ${useratividade.usuario_id}?'),
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

    // Se o usuário-atividade confirmou a exclusão, enviar a requisição DELETE
    if (confirmDelete == true) {
      await _sendDeleteRequest(useratividade.id);
    }
  }

  Future<void> _sendDeleteRequest(int useratividadeId) async {
    String url = 'http://localhost:3000/usuario-atividades/$useratividadeId'; // URL para excluir o usuário-atividade com o ID específico

    try {
      await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      print('Usuário excluído com sucesso');
    } catch (error) {
      print('Erro ao excluir usuário-atividade: $error');
    }
  }

  void _showEditUserAtividadeDialog(UserAtividade useratividade) async {
    TextEditingController usuario_idController = TextEditingController(text: useratividade.usuario_id.toString());
  TextEditingController atividade_idController = TextEditingController(text: useratividade.atividade_id.toString());
  TextEditingController notaController =  TextEditingController(text: useratividade.nota.toString());
  TextEditingController entregaController = TextEditingController(text: useratividade.entrega.toString());
await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Editar Usuário-Atividade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<List<dynamic>>(
              future: _futureUsuarios,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Text('Nenhum usuário encontrado');
                } else {
                  List<DropdownMenuItem<dynamic>> items =
                      snapshot.data!.map<DropdownMenuItem<dynamic>>((usuario) {
                    return DropdownMenuItem<dynamic>(
                      value: usuario['id'],
                      child: Text(usuario['nome']),
                    );
                  }).toList();

                  return DropdownButtonFormField(
                    value: useratividade.usuario_id,
                    items: items,
                    onChanged: (newValue) {
                      setState(() {
                        useratividade.usuario_id = newValue;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Usuário'),
                    );
                  }
                },
              ),
              FutureBuilder<List<dynamic>>(
                future: _futureAtividades,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<DropdownMenuItem<dynamic>> items = snapshot.data!.map<DropdownMenuItem<dynamic>>((atividade) {
                      return DropdownMenuItem<dynamic>(
                        value: atividade['id'],
                        child: Text(atividade['titulo']),
                      );
                    }).toList();

                    return DropdownButtonFormField(
                      value: useratividade.atividade_id,
                      items: items,
                      onChanged: (newValue) {
                        setState(() {
                          useratividade.atividade_id = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Atividade'),
                    );
                  }
                },
              ),
              TextField(
                controller: notaController,
                decoration: InputDecoration(labelText: 'Nota'),
              ),
              TextField(
                controller: entregaController,
                decoration: InputDecoration(labelText: 'Entrega'),
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
                _updateUserAtividade(useratividade.id, useratividade.usuario_id, useratividade.atividade_id, notaController.text, entregaController.text);
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _updateUserAtividade(int useratividadeId, int newUser, int newAtividade, String newNota, String newEntrega) async {
    String url = 'http://localhost:3000/usuario-atividades/$useratividadeId';

    try {
      await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'usuario_id': newUser,
          'atividade_id': newAtividade,
          'nota': int.parse(newNota),
          'entrega': newEntrega,
          'id': useratividadeId,
        }),
      );
      print('Usuário-Atividade atualizado com sucesso');
    } catch (error) {
      print('Erro ao atualizar usuário-atividade: $error');
    }
  }
}

class UserAtividade {
  final int id;
  int usuario_id;
  int atividade_id;
  int nota;
  String entrega;

  UserAtividade({required this.id, required this.usuario_id, required this.atividade_id, required this.nota, required this.entrega});

  factory UserAtividade.fromJson(Map<String, dynamic> json) {
  return UserAtividade(
    id: json['id'] ?? 0,
    usuario_id: json['usuario_id'] ?? 0, // Define um valor padrão se for nulo
    atividade_id: json['atividade_id'] ?? 0, // Define um valor padrão se for nulo
    nota: json['nota'] ?? 0,
    entrega: json['entrega'],
  );
}
}
