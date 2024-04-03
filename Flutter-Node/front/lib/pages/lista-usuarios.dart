import 'dart:convert';
import 'package:front/pages/form-usuario.dart';
import 'package:front/pages/inicio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: ListaUsuarios(),
  ));
}

class ListaUsuarios extends StatefulWidget {
  @override
  _ListaUsuariosState createState() => _ListaUsuariosState();
}

class _ListaUsuariosState extends State<ListaUsuarios> {
  late Future<List<User>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:3000/usuarios'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => User.fromJson(user)).toList().cast<User>();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuários'),
         actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormUsuario()),
            );
          },
        ),
      ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 0.8, // 80% da altura da tela
        child: FutureBuilder<List<User>>(
          future: _futureUsers,
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
                  User user = snapshot.data![index];
                  return ListTile(
                    title: Text(user.nome),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditUserDialog(user);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteUser(user);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _deleteUser(User user) async {
  // Mostrar um diálogo de confirmação
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Tem certeza de que deseja excluir o usuário ${user.nome}?'),
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

  // Se o usuário confirmou a exclusão, enviar a requisição DELETE
  if (confirmDelete == true) {
    await _sendDeleteRequest(user.id);
  }
}

Future<void> _sendDeleteRequest(int userId) async {
  String url = 'http://localhost:3000/usuarios/$userId'; // URL para excluir o usuário com o ID específico
  
  try {
    await http.delete(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );
    print('Usuário excluído com sucesso');
  } catch (error) {
    print('Erro ao excluir usuário: $error');
  }
}


  void _showEditUserDialog(User user) async {
    TextEditingController nomeController = TextEditingController(text: user.nome);
    TextEditingController emailController = TextEditingController(text: user.email);
    TextEditingController senhaController = TextEditingController(text: user.senha);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Usuário'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
               TextField(
                controller: senhaController,
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
                _updateUser(user.id, nomeController.text, emailController.text, senhaController.text);
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

  void _updateUser(int userId, String newName, String newEmail, String newSenha) async {
  String url = 'http://localhost:3000/usuarios/$userId';
  
  try {
    await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'nome': newName,
        'email': newEmail,
        'senha': newSenha,
        'id': userId,
      }),
    );
    print('Usuário atualizado com sucesso');
  } catch (error) {
    print('Erro ao atualizar usuário: $error');
  }
}
}

class User {
  final int id;
  final String nome;
  final String email;
  final String senha;

  User({required this.id, required this.nome, required this.email, required this.senha});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'],
    );
  }
}
