import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

class TodoItem extends StatelessWidget {
  TodoItem({required this.todo, required this.onTodoChanged})
      : super(key: ObjectKey(todo));

  final Todo todo;
  final onTodoChanged;

  TextStyle? getTextStyle(bool checked) {
    if (!checked) return null;
    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: CircleAvatar(
        child: Text(todo.name[0]),
      ),
      title: Text(todo.name, style: getTextStyle(todo.checked)),
    );
  }
}
