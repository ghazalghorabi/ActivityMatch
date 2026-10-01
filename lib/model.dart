import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'todo.dart';

class TodoModel extends ChangeNotifier {
  List<Todo> _todos = [];
  String _filter = 'all';

  List<Todo> get todos {
    if (_filter == 'done') {
      return _todos.where((todo) => todo.done).toList();
    }

    if (_filter == 'undone') {
      return _todos.where((todo) => !todo.done).toList();
    }

    return _todos;
  }

  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();

    String? key = prefs.getString('apiKey');

    if (key == null) {
      key = await TodoApi.register();
      await prefs.setString('apiKey', key);
    }

    return key;
  }

  Future<void> loadTodos() async {
    final key = await _getApiKey();

    _todos = await TodoApi.getTodos(key);

    notifyListeners();
  }

  Future<void> addTodo(String title) async {
    final key = await _getApiKey();

    final todo = Todo(title: title, done: false);

    _todos = await TodoApi.addTodo(key, todo);

    notifyListeners();
  }

  Future<void> toggleTodo(Todo todo) async {
    final key = await _getApiKey();

    final updatedTodo = Todo(id: todo.id, title: todo.title, done: !todo.done);

    await TodoApi.updateTodo(key, updatedTodo);

    await loadTodos();
  }

  Future<void> deleteTodo(Todo todo) async {
    final key = await _getApiKey();

    await TodoApi.deleteTodo(key, todo);

    await loadTodos();
  }

  void setFilter(String filter) {
    _filter = filter;

    notifyListeners();
  }
}
