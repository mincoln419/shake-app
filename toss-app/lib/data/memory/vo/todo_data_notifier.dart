import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/data/memory/vo/vo_todo.dart';
import 'package:flutter/cupertino.dart';

class TodoDataNotifier extends ValueNotifier<List<Todo>>{
  TodoDataNotifier() : super([]);


  void addToto(Todo todo){
    value.add(todo);
    notifyListeners();
  }

  void removeTodo(Todo todo) async{
    value.remove(todo);
    notifyListeners();
  }
}