import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/dart/extension/datetime_extension.dart';
import 'package:fast_app_base/common/widget/rounded_container.dart';
import 'package:fast_app_base/data/memory/vo/vo_todo.dart';
import 'package:fast_app_base/screen/main/tab/todo/w_todo_status.dart';
import 'package:flutter/material.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (direction){
        context.holder.todoDataNotifier.removeTodo(todo);
      },
      background: RoundedContainer(
        color: context.appColors.deleteBackground,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Width(20),
            Icon(
              EvaIcons.trashOutline,
              color: Colors.white,
            )
          ],
        ),

      ),
      secondaryBackground: RoundedContainer(
        color: context.appColors.deleteBackground,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              EvaIcons.trashOutline,
              color: Colors.white,
            ),
            Width(20),
          ],
        ),

      ),
      key: ValueKey(todo.id),
      child: RoundedContainer(
        margin: const EdgeInsets.only(bottom: 6),
        color: context.appColors.itemBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          todo.dueDtm.relativeDays.text.make(),
          Row(
            children: [
              TodoStatusWidget(todo),
              Expanded(
                child: todo.title.text.size(20).medium.make(),
              ),
              IconButton(
                onPressed: () async {
                  context.holder.editTodo(todo);
                },
                icon: const Icon(EvaIcons.editOutline),
              )
            ],
          )
        ],
      ).pOnly(top: 15, left: 5, bottom: 10)
        ,),
    );
  }
}
