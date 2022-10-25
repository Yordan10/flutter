import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import 'learn_flutter_screen.dart';

class Todo {
  Todo({required this.id, required this.name, required this.checked});

  final int id;
  final String name;
  bool checked;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(id: json['id'], name: json['text'], checked: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'text': name,
      'id': id,
    };
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final dataProvider = Provider.of<TodoProvider>(context, listen: false);
    dataProvider.getMyData();
  }

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
                    context
                        .read<TodoProvider>()
                        .addTodoItem(textFieldController.text);
                    textFieldController.clear();
                  }),
                  child: const Text("Add"))
            ],
          );
        });
  }

  Widget customButton(
      {required String title,
      required IconData icon,
      required VoidCallback onclick}) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
          onPressed: onclick,
          child: Row(
            children: [Icon(icon), const SizedBox(width: 20), Text(title)],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<TodoProvider>(context);
    List<Todo> todos = dataProvider.todos;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
              hasScrollBody: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    // flex: 3,
                    fit: FlexFit.loose,

                    child: ListView.separated(
                      itemCount: todos.length,
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
                                return Future.value(
                                    direction == DismissDirection.endToStart);
                              }
                            },
                            onDismissed: (DismissDirection direction) async {
                              if (direction == DismissDirection.endToStart) {
                                print("delete");

                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: Text(
                                        'Deleted todo with id: ${data.id}'),
                                    action: SnackBarAction(
                                      label: "UNDO",
                                      onPressed: () {
                                        context
                                            .read<TodoProvider>()
                                            .insertTodo(index, data);
                                      },
                                    ),
                                  ));
                              }
                              context.read<TodoProvider>().deleteItem(data);
                            },
                            child: TodoItem(
                              todo: data,
                              onTodoChanged: context
                                  .read<TodoProvider>()
                                  .handleTodoChanged,
                            ));
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(color: Colors.black);
                      },
                    ),
                  ),
                  Center(
                    // flex: 1,
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
                ],
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => displayDialog(),
          tooltip: 'Add item',
          child: const Icon(Icons.add)),
    );
  }

  List<Widget> listView(BuildContext context) {
    return [];
  }
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
