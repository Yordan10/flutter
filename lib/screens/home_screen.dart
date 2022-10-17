import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/todo_item.dart';
import 'learn_flutter_screen.dart';

class Todo {
  Todo({required this.id, required this.name, required this.checked});
  final int id;
  final String name;
  bool checked;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> todos = <Todo>[];

  final TextEditingController textFieldController = TextEditingController();

  Future<void> displayDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add new todo item'),
            content: TextField(
              controller: textFieldController,
              decoration: const InputDecoration(hintText: 'Type your new todo'),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: (() {
                    Navigator.of(context).pop();
                    addTodoItem(textFieldController.text);
                  }),
                  child: const Text("Add"))
            ],
          );
        });
  }

  void addTodoItem(String name) {
    var rng = Random();

    int id = rng.nextInt(1000);
    // debugPrint('${id}');
    setState(() {
      todos.add(Todo(id: id, name: name, checked: false));
    });
    textFieldController.clear();
  }

  void handleTodoChanged(Todo todo) {
    setState(() {
      todo.checked = !todo.checked;
    });
  }

  final leftEditIcon = Container(
    color: Colors.green,
    alignment: Alignment.centerLeft,
    child: const Icon(Icons.edit),
  );
  final rightDeleteIcon = Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    child: const Icon(Icons.delete),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: listView(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => displayDialog(),
          tooltip: 'Add item',
          child: const Icon(Icons.add)),
    );
  }

  List<Widget> listView(BuildContext context) {
    return [
      ListView.separated(
        itemCount: todos.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final data = todos[index];
          return Dismissible(
              key: ObjectKey(todos[index]),
              background: leftEditIcon,
              secondaryBackground: rightDeleteIcon,
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.startToEnd) {
                  print("Go to edit page ");
                  return false;
                } else {
                  return Future.value(direction == DismissDirection.endToStart);
                }
              },
              onDismissed: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart) {
                  print("delete");

                  setState(() {
                    todos.removeWhere((todo) => todo.id == data.id);

                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text('Deleted todo with id: ${data.id}'),
                        action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () {
                            setState(() {
                              todos.insert(index, data);
                            });
                          },
                        ),
                      ));
                  });
                }
              },
              child: TodoItem(
                todo: data,
                onTodoChanged: handleTodoChanged,
              ));
        },
        separatorBuilder: (context, index) {
          return const Divider(color: Colors.black);
        },
      ),
      Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const LearnFlutterPage();
                },
              ),
            );
          },
          child: const Text('Learn me'),
        ),
      ),
    ];
  }
}
