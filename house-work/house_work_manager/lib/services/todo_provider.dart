import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../models/history.dart';
import '../models/category.dart';
import '../models/collaboration_mode.dart';
import '../models/connection.dart';
import '../services/database_service.dart';
import '../services/user_provider.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final todosProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return TodoNotifier(databaseService, ref);
});

final todayTodosProvider = FutureProvider<List<Todo>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  final userId = currentUser?.id;
  
  if (userId == null) {
    return [];
  }
  
  // 협업 모드 확인
  final collaborationMode = ref.watch(collaborationModeProvider);
  
  return collaborationMode.when(
    data: (mode) async {
      if (mode == CollaborationMode.connected) {
        // 협업 모드: 연결된 사용자들의 할일 가져오기
        final connection = await ref.read(activeConnectionProvider.future);
        if (connection != null) {
          final partnerId = connection.user1Id == userId ? connection.user2Id : connection.user1Id;
          return await databaseService.getCollaborativeTodosByDate(
            DateTime.now(), 
            userId: userId, 
            partnerId: partnerId
          );
        } else {
          // 연결 정보가 없으면 개인 데이터만
          return await databaseService.getTodosByDate(DateTime.now(), userId: userId);
        }
      } else {
        // 개인 모드 또는 pending 모드: 개인 데이터만
        return await databaseService.getTodosByDate(DateTime.now(), userId: userId);
      }
    },
    loading: () async {
      // 로딩 중: 개인 데이터만
      return await databaseService.getTodosByDate(DateTime.now(), userId: userId);
    },
    error: (error, stack) async {
      // 오류 발생: 개인 데이터만
      return await databaseService.getTodosByDate(DateTime.now(), userId: userId);
    },
  );
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
    final currentUser = _ref.read(currentUserProvider);
    final userId = currentUser?.id;
    
    print('=== _loadTodos 호출 ===');
    print('현재 사용자: ${currentUser?.email}');
    print('현재 사용자 ID: $userId');
    print('currentUser 객체: $currentUser');
    
    if (userId == null) {
      print('사용자 ID가 null이므로 빈 리스트 반환');
      state = [];
      return;
    }
    
    // 협업 모드 확인
    final collaborationMode = _ref.read(collaborationModeProvider);
    
    collaborationMode.when(
      data: (mode) async {
        print('협업 모드: $mode');
        if (mode == CollaborationMode.connected) {
          // 협업 모드: 연결된 사용자들의 할일 가져오기
          final connection = await _ref.read(activeConnectionProvider.future);
          if (connection != null) {
            final partnerId = connection.user1Id == userId ? connection.user2Id : connection.user1Id;
            print('협업 모드 - 파트너 ID: $partnerId');
            final todos = await _databaseService.getCollaborativeTodos(userId: userId, partnerId: partnerId);
            print('협업 모드 - 로드된 할일 개수: ${todos.length}');
            state = todos;
          } else {
            // 연결 정보가 없으면 개인 데이터만
            print('협업 모드이지만 연결 정보가 없음 - 개인 데이터만 로드');
            final todos = await _databaseService.getAllTodos(userId: userId);
            print('개인 데이터 - 로드된 할일 개수: ${todos.length}');
            state = todos;
          }
        } else {
          // 개인 모드 또는 pending 모드: 개인 데이터만
          print('개인 모드 - 개인 데이터만 로드');
          print('전달할 userId: $userId');
          final todos = await _databaseService.getAllTodos(userId: userId);
          print('개인 데이터 - 로드된 할일 개수: ${todos.length}');
          state = todos;
        }
      },
      loading: () async {
        // 로딩 중: 개인 데이터만
        print('협업 모드 로딩 중 - 개인 데이터만 로드');
        final todos = await _databaseService.getAllTodos(userId: userId);
        print('개인 데이터 - 로드된 할일 개수: ${todos.length}');
        state = todos;
      },
      error: (error, stack) async {
        // 오류 발생: 개인 데이터만
        print('협업 모드 오류 - 개인 데이터만 로드');
        final todos = await _databaseService.getAllTodos(userId: userId);
        print('개인 데이터 - 로드된 할일 개수: ${todos.length}');
        state = todos;
      },
    );
  }

  Future<void> addTodo(Todo todo) async {
    final id = await _databaseService.insertTodo(todo);
    final newTodo = todo.copyWith(id: id);
    state = [...state, newTodo];
    // 상태 갱신
    _ref.invalidate(todayTodosProvider);
    _ref.invalidate(todosProvider);
  }

  Future<void> updateTodo(Todo todo) async {
    await _databaseService.updateTodo(todo);
    state = state.map((t) => t.id == todo.id ? todo : t).toList();
    // 상태 갱신
    _ref.invalidate(todayTodosProvider);
    _ref.invalidate(todosProvider);
  }

  Future<void> deleteTodo(int id) async {
    await _databaseService.deleteTodo(id);
    state = state.where((todo) => todo.id != id).toList();
    // 상태 갱신
    _ref.invalidate(todayTodosProvider);
    _ref.invalidate(todosProvider);
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
      }
      
      state = state.map((t) => t.id == todo.id ? updatedTodo : t).toList();
      
      // todayTodosProvider를 invalidate하여 UI 갱신
      _ref.invalidate(todayTodosProvider);
      _ref.invalidate(todosProvider);
    } catch (e) {
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