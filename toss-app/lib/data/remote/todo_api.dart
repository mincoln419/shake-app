import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_app_base/data/memory/vo/vo_todo.dart';
import 'package:fast_app_base/data/network/result/api_error.dart';
import 'package:fast_app_base/data/simple_result.dart';
import 'package:fast_app_base/data/todo_repository.dart';

class TodoApi implements TodoRepository<ApiError>{

  final client = Dio(BaseOptions(baseUrl: Platform.isAndroid ? 'http://10.0.2.2:8080/' : 'http://localhost:8080/'));

  TodoApi._();

  static TodoApi instance = TodoApi._();

  @override
  Future<SimpleResult<void, ApiError>> addTodo(Todo todo) {
    // TODO: implement addTodo
    throw UnimplementedError();
  }

  @override
  Future<SimpleResult<List<Todo>, ApiError>> getTodoList() {
    // TODO: implement getTodoList
    throw UnimplementedError();
  }

  @override
  Future<SimpleResult<void, ApiError>> removeTodo(int id) {
    // TODO: implement removeTodo
    throw UnimplementedError();
  }

  @override
  Future<SimpleResult<void, ApiError>> updateTodo(Todo todo) {
    // TODO: implement updateTodo
    throw UnimplementedError();
  }
  
}