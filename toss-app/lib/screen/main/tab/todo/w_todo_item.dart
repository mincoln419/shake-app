import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/dart/extension/datetime_extension.dart';
import 'package:fast_app_base/common/widget/rounded_container.dart';
import 'package:fast_app_base/data/memory/vo/enum_todo_status.dart';
import 'package:fast_app_base/data/memory/vo/vo_todo.dart';
import 'package:fast_app_base/screen/main/tab/todo/w_todo_status.dart';
import 'package:flutter/material.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      color: context.appColors.itemBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        todo.dueDtm.formattedDate.text.make(),
        Row(
          children: [
            TodoStatusWidget(todo),
            Expanded(
              child: todo.title.text.size(20).medium.make(),
            ),
            IconButton(
              onPressed: () async {},
              icon: const Icon(EvaIcons.editOutline),
            )
          ],
        )
      ],
    ).pOnly(top: 15, left: 5, bottom: 10)
      ,);
  }
}
