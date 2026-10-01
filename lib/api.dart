import 'dart:convert';

import 'package:http/http.dart' as http;

import 'todo.dart';

class TodoApi {
  static const String baseUrl = 'https://todoapp-api.apps.k8s.gu.se';

  static Future<String> register() async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.get(url);

    return response.body;
  }

  static Future<List<Todo>> getTodos(String key) async {
    final url = Uri.parse('$baseUrl/todos?key=$key');

    final response = await http.get(url);

    final List<dynamic> jsonList = jsonDecode(response.body);

    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }

  static Future<List<Todo>> addTodo(String key, Todo todo) async {
    final url = Uri.parse('$baseUrl/todos?key=$key');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    final List<dynamic> jsonList = jsonDecode(response.body);

    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }

  static Future<void> updateTodo(String key, Todo todo) async {
    final url = Uri.parse('$baseUrl/todos/${todo.id}?key=$key');

    await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );
  }

  static Future<void> deleteTodo(String key, Todo todo) async {
    final url = Uri.parse('$baseUrl/todos/${todo.id}?key=$key');

    await http.delete(url);
  }
}
