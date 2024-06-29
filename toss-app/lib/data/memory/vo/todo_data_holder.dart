import 'package:fast_app_base/common/dart/extension/datetime_extension.dart';
import 'package:fast_app_base/data/local/local_db.dart';
import 'package:fast_app_base/data/memory/vo/todo_status.dart';
import 'package:fast_app_base/data/memory/vo/vo_todo.dart';
import 'package:fast_app_base/data/remote/todo_api.dart';
import 'package:fast_app_base/data/todo_repository.dart';
import 'package:fast_app_base/screen/dialog/d_confirm.dart';
import 'package:fast_app_base/screen/main/write/d_write_todo.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TodoDataHolder extends GetxController {
  late final RxList<Todo> todoList = <Todo>[].obs;

  final TodoRepository todoRepository = TodoApi.instance;

  @override
  void onInit() async {
    final getTodoResult = await todoRepository.getTodoList();
    getTodoResult.runIfSuccess((data) => todoList.addAll(data));
    super.onInit();
  }

  void changeTodoStatus(Todo todo) async{
    switch(todo.status){
      case TodoStatus.incomplete:
        todo.status = TodoStatus.ongoing;
      case TodoStatus.ongoing:
        todo.status = TodoStatus.complete;
      case TodoStatus.complete:
        final confirm = await ConfirmDialog("초기화 하시겠습니까?").show();
        confirm?.runIfSuccess((data) => {
          todo.status = TodoStatus.incomplete
        });
    }
    todoRepository.updateTodo(todo);
    todoList.refresh();
  }

  void addTodo() async{
    final result = await WriteTodoDialog().show();
    if (result != null) {
      String text = result.text;
      DateTime dueDtm = result.dateTime;
      debugPrint(text);
      debugPrint(dueDtm.formattedDate);
      Todo todo = Todo(
        id: dueDtm.millisecond,
        title: text,
        dueDtm: dueDtm,
      );
      todoList.add(todo);
      todoRepository.addTodo(todo);
    }

  }

  void editTodo(Todo todo) async{
    final result = await WriteTodoDialog(todoForEdit : todo).show();

    if(result !=null) {
      todo.title = result.text;
      todo.dueDtm = result.dateTime;
      todoRepository.updateTodo(todo);
      todoList.refresh();
    }
  }

  void remove(Todo todo) {
    todoRepository.removeTodo(todo.id);
    todoList.remove(todo);
  }
}

mixin class TodoDataProvider{
  late final TodoDataHolder todoData = Get.find();
}