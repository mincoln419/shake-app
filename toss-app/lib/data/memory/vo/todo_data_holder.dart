import 'package:fast_app_base/data/memory/vo/todo_data_notifier.dart';
import 'package:flutter/cupertino.dart';

class TodoDataHolder extends InheritedWidget {
  final TodoDataNotifier todoDataNotifier;

  const TodoDataHolder({
    super.key,
    required this.todoDataNotifier,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }

  static TodoDataHolder of(BuildContext context){
    TodoDataHolder inherited = (context.dependOnInheritedWidgetOfExactType())!;
    return inherited;
  }
}
