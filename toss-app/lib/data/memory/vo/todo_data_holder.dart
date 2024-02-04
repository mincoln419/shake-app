import 'package:fast_app_base/common/dart/extension/datetime_extension.dart';
import 'package:fast_app_base/data/memory/vo/enum_todo_status.dart';
import 'package:fast_app_base/data/memory/vo/vo_todo.dart';
import 'package:fast_app_base/screen/dialog/d_confirm.dart';
import 'package:fast_app_base/screen/main/write/d_write_todo.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TodoDataHolder extends GetxController {
  final RxList<Todo> todoList = <Todo>[].obs;

  static TodoDataHolder _of(BuildContext context){
    TodoDataHolder inherited = (context.dependOnInheritedWidgetOfExactType())!;
    return inherited;
  }

  void changeTodoStatus(Todo todo) async{
    switch(todo.status){
      case TodoStatus.undo:
        todo.status = TodoStatus.onGoing;
      case TodoStatus.onGoing:
        todo.status = TodoStatus.done;
      case TodoStatus.done:
        final confirm = await ConfirmDialog("초기화 하시겠습니까?").show();
        confirm?.runIfSuccess((data) => {
          todo.status = TodoStatus.undo
        });
    }
    todoList.refresh();
  }

  void addTodo() async{
    final result = await WriteTodoDialog().show();
    if (result != null) {
      String text = result.text;
      DateTime dueDtm = result.dateTime;
      debugPrint(text);
      debugPrint(dueDtm.formattedDate);
      todoList.add(Todo(
        id: dueDtm.millisecond,
        title: text,
        dueDtm: dueDtm,
      ));
    }
  }

  void editTodo(Todo todo) async{
    final result = await WriteTodoDialog(todoForEdit : todo).show();

    if(result !=null) {
      todo.title = result.text;
      todo.dueDtm = result.dateTime;
      todoList.refresh();
    }
  }

  void remove(Todo todo) {
    todoList.remove(todo);
    todoList.refresh();
  }
}

mixin class TodoDataProvider{
  late final TodoDataHolder todoData = Get.find();
}