
import 'package:fast_app_base/data/local/collection/todo_db_model.dart';
import 'package:fast_app_base/data/memory/vo/todo_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';



part 'vo_todo.g.dart';

@JsonSerializable()
class Todo {
  Todo({
    required this.id,
    required this.title,
    required this.dueDtm,
    this.modifyTime,
    TodoStatus? status,
    DateTime? createdDtm,
  })  : createdTime = createdDtm ?? DateTime.now(),
        status = status ?? TodoStatus.incomplete;

  int id;
  String title;
  final DateTime createdTime;
  DateTime? modifyTime;
  DateTime dueDtm;
  TodoStatus status;

  factory Todo.fromJson(Map<String, Object?> json) => _$TodoFromJson(json);

  factory Todo.fromDB(TodoDbModel e) {
    return Todo(
        id: e.id,
        title: e.title,
        dueDtm: e.dueDate,
        createdDtm: e.createdTime,
        status: e.status,
        modifyTime: e.modifyTime);
  }

  TodoDbModel toDbModel() => TodoDbModel(id, createdTime, modifyTime, title, dueDtm, status);

  Map<String, dynamic> toJson() => _$TodoToJson(this);
}
