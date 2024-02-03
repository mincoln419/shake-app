import 'enum_todo_status.dart';

class Todo {
  int id;
  String title;
  final DateTime createdDtm;
  DateTime? updateDtm;
  DateTime dueDtm;
  TodoStatus status;

  Todo({
    required this.id,
    required this.title,
    required this.dueDtm,
    this.status = TodoStatus.undo,
  }) : createdDtm = DateTime.now();
}


