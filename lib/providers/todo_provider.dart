import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home_screen.dart';

class TodoProvider extends ChangeNotifier {
  static const api = "http://192.168.70.73:5000/goals";

  List<Todo> _todos = [];
  bool isLoading = false;

  List<Todo> get todos => _todos;

  getMyData() async {
    isLoading = true;
    _todos = await getTodos();
    isLoading = false;
    notifyListeners();
  }

  Future<List<Todo>> getTodos() async {
    print('entered get todos');
    List<Todo> newTodos = [];
    final response = await http.get(Uri.parse(api));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      for (var t in jsonResponse) {
        newTodos.add(Todo.fromJson(t));
      }
      return newTodos;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<String> addTodoItem(String name) async {
    var rng = Random();
    int id = rng.nextInt(1000);
    Todo newTodo = Todo(id: id, name: name, checked: false);
    var body = json.encode(newTodo.toJson());

    final response = await http.post(Uri.parse(api),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.body == 'Goal added successfully') {
      getMyData();
      return ('Goal added successfully');
    } else {
      throw Exception('Failed to create todo.');
    }
  }

  void deleteItem(data) {
    final response = http.delete(Uri.parse('$api/${data.id}'),
        headers: {"Content-Type": "application/json"});

    getMyData();
    // if (response == 200) {
    //   getMyData();
    // } else {
    //   throw Exception('Failed to create todo.');
    // }

    // _todos.removeWhere((todo) => todo.id == data.id);
    // notifyListeners();
  }

  void insertTodo(index, data) {
    _todos.insert(index, data);
    notifyListeners();
  }

  void handleTodoChanged(Todo todo) {
    todo.checked = !todo.checked;
    notifyListeners();
  }
}
