import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/screen/main/tab/todo/w_todo_item.dart';
import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.holder.todoDataNotifier,
      builder: (context, todoList, child) {
        return todoList.isEmpty
            ? '할일을 작성하세요'.text.size(30).makeCentered()
            : Column(
                children: todoList
                    .map((e) => TodoItem(todo: e))
                    .toList(),
              );
      },
    );
  }
}
