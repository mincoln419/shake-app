import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../models/history.dart';
import '../models/category.dart';
import 'database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final todosProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return TodoNotifier(databaseService, ref);
});

final todayTodosProvider = FutureProvider<List<Todo>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getTodosByDate(DateTime.now());
});

final historyProvider = StateNotifierProvider<HistoryNotifier, List<History>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return HistoryNotifier(databaseService);
});

final categoriesProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return CategoryNotifier(databaseService);
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  final DatabaseService _databaseService;
  final Ref _ref;

  TodoNotifier(this._databaseService, this._ref) : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _databaseService.getAllTodos();
    state = todos;
  }

  Future<void> addTodo(Todo todo) async {
    print('TodoNotifier.addTodo 호출됨: ${todo.title}');
    final id = await _databaseService.insertTodo(todo);
    print('DB insert 완료, ID: $id');
    final newTodo = todo.copyWith(id: id);
    state = [...state, newTodo];
    print('State 업데이트 완료, 현재 할일 개수: ${state.length}');
  }

  Future<void> updateTodo(Todo todo) async {
    await _databaseService.updateTodo(todo);
    state = state.map((t) => t.id == todo.id ? todo : t).toList();
  }

  Future<void> deleteTodo(int id) async {
    await _databaseService.deleteTodo(id);
    state = state.where((todo) => todo.id != id).toList();
  }

  Future<void> toggleTodoCompletion(Todo todo) async {
    try {
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );
      
      await _databaseService.updateTodo(updatedTodo);
      
      // 완료된 경우에만 히스토리에 추가 (중복 방지)
      if (updatedTodo.isCompleted && updatedTodo.completedAt != null) {
        print('할일 완료됨: ${updatedTodo.title}');
        
        // 이미 히스토리에 있는지 확인 (더 정확한 중복 체크)
        final existingHistory = _ref.read(historyProvider).where(
          (h) => h.todoId == updatedTodo.id && 
                 h.completedAt.year == updatedTodo.completedAt!.year &&
                 h.completedAt.month == updatedTodo.completedAt!.month &&
                 h.completedAt.day == updatedTodo.completedAt!.day
        ).toList();
        
        if (existingHistory.isEmpty) {
          print('새 이력 추가: ${updatedTodo.title}');
          final history = History(
            todoId: updatedTodo.id!,
            title: updatedTodo.title,
            category: updatedTodo.category,
            completedAt: updatedTodo.completedAt!,
            completionTime: updatedTodo.completedAt!
                .difference(updatedTodo.createdAt)
                .inMinutes,
          );
          
          // HistoryNotifier를 통해 히스토리 추가
          await _ref.read(historyProvider.notifier).addHistory(history);
          print('이력 추가 완료: ${history.title}');
        } else {
          print('이미 존재하는 이력: ${updatedTodo.title}');
        }
      }
      
      state = state.map((t) => t.id == todo.id ? updatedTodo : t).toList();
    } catch (e) {
      print('할일 상태 변경 중 오류 발생: $e');
      rethrow; // 에러를 다시 던져서 UI에서 처리할 수 있도록 함
    }
  }

  Future<void> refreshTodos() async {
    await _loadTodos();
  }
}

class HistoryNotifier extends StateNotifier<List<History>> {
  final DatabaseService _databaseService;

  HistoryNotifier(this._databaseService) : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _databaseService.getAllHistory();
    state = history;
  }

  Future<void> addHistory(History history) async {
    final id = await _databaseService.insertHistory(history);
    final newHistory = history.copyWith(id: id);
    state = [newHistory, ...state];
  }

  Future<void> deleteHistory(int id) async {
    await _databaseService.deleteHistory(id);
    state = state.where((h) => h.id != id).toList();
  }

  Future<List<History>> getHistoryByDateRange(DateTime startDate, DateTime endDate) async {
    return await _databaseService.getHistoryByDateRange(startDate, endDate);
  }

  Future<void> refreshHistory() async {
    await _loadHistory();
  }
}

class CategoryNotifier extends StateNotifier<List<Category>> {
  final DatabaseService _databaseService;

  CategoryNotifier(this._databaseService) : super([]) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _databaseService.getAllCategories();
    state = categories;
  }

  Future<void> addCategory(Category category) async {
    final id = await _databaseService.insertCategory(category);
    final newCategory = category.copyWith(id: id);
    state = [...state, newCategory];
  }

  Future<void> updateCategory(Category category) async {
    await _databaseService.updateCategory(category);
    state = state.map((c) => c.id == category.id ? category : c).toList();
  }

  Future<void> deleteCategory(int id) async {
    await _databaseService.deleteCategory(id);
    state = state.where((c) => c.id != id).toList();
  }

  Future<bool> categoryExists(String name) async {
    return await _databaseService.categoryExists(name);
  }

  Future<void> refreshCategories() async {
    await _loadCategories();
  }
} 