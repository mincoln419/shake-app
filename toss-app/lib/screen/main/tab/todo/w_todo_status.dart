import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/widget/w_fire.dart';
import 'package:fast_app_base/data/memory/vo/todo_status.dart';

import 'package:fast_app_base/data/memory/vo/vo_todo.dart';
import 'package:flutter/material.dart';

class TodoStatusWidget extends StatelessWidget with TodoDataProvider {
  final Todo todo;

  TodoStatusWidget(this.todo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: () {
        todoData.changeTodoStatus(todo);
      },
      child: SizedBox(
        width: 50,
        height: 50,
        child: switch (todo.status) {
          TodoStatus.ongoing => const FireWidget(),
          TodoStatus.incomplete => const Checkbox(
            value: false,
            onChanged: null,
            ),
          TodoStatus.complete => Checkbox(
            value: true,
            onChanged: null,
            fillColor:
            MaterialStateProperty.all(context.appColors.checkBoxColor),
          ),
        },
      ),
    );
  }
}
