import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../models/user.dart';
import '../models/connection.dart';
import '../models/collaboration_mode.dart';
import '../services/todo_provider.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';

class RecentTodosSuggestions extends ConsumerWidget {
  final Function(Todo) onTodoSelected;

  const RecentTodosSuggestions({
    super.key,
    required this.onTodoSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final currentUser = ref.watch(currentUserProvider);
        final userId = currentUser?.id;
        
        return FutureBuilder<List<Todo>>(
          future: ref.read(databaseServiceProvider).getRecentCompletedTodos(userId: userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }

            if (snapshot.hasError) {
              return const SizedBox.shrink();
            }

            final recentTodos = snapshot.data ?? [];
            
            if (recentTodos.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '최근 완료된 할일',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.text),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recentTodos.length,
                    itemBuilder: (context, index) {
                      final todo = recentTodos[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => _showQuickAddDialog(context, ref, todo),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(todo.category),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    todo.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName) {
      case '요리':
        return Colors.orange;
      case '청소':
        return Colors.blue;
      case '빨래':
        return Colors.green;
      case '쇼핑':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showQuickAddDialog(BuildContext context, WidgetRef ref, Todo originalTodo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할일 추가'),
        content: Text('"${originalTodo.title}"을 다시 추가하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addQuickTodo(context, ref, originalTodo);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _addQuickTodo(BuildContext context, WidgetRef ref, Todo originalTodo) {
    // 현재 사용자 가져오기
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 정보를 찾을 수 없습니다'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 협업 모드 확인
    final collaborationMode = ref.read(collaborationModeProvider);
    
    collaborationMode.when(
      data: (mode) {
        if (mode == CollaborationMode.connected) {
          // 협업 모드: 담당자 선택 다이얼로그 표시
          _showAssigneeSelectionDialog(context, ref, originalTodo, currentUser);
        } else {
          // 개인 모드 또는 pending 모드: 현재 사용자를 담당자로 설정
          _createTodoWithAssignee(ref, originalTodo, currentUser.id!);
        }
      },
      loading: () {
        // 로딩 중: 현재 사용자를 담당자로 설정
        _createTodoWithAssignee(ref, originalTodo, currentUser.id!);
      },
      error: (error, stack) {
        // 오류 발생: 현재 사용자를 담당자로 설정
        _createTodoWithAssignee(ref, originalTodo, currentUser.id!);
      },
    );
  }

  void _showAssigneeSelectionDialog(BuildContext context, WidgetRef ref, Todo originalTodo, User currentUser) {
    // 상대방 정보 가져오기
    ref.read(activeConnectionProvider).when(
      data: (connection) {
        if (connection == null) {
          _createTodoWithAssignee(ref, originalTodo, currentUser.id!);
          return;
        }

        // 상대방 ID 찾기
        final partnerId = connection.user1Id == currentUser.id ? connection.user2Id : connection.user1Id;
        
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('담당자 선택'),
            content: const Text('이 할일의 담당자를 선택해주세요'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _createTodoWithAssignee(ref, originalTodo, currentUser.id!);
                },
                child: const Text('나'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _createTodoWithAssignee(ref, originalTodo, partnerId);
                },
                child: const Text('상대방'),
              ),
            ],
          ),
        );
      },
      loading: () {
        // 로딩 중: 현재 사용자를 담당자로 설정
        _createTodoWithAssignee(ref, originalTodo, currentUser.id!);
      },
      error: (error, stack) {
        // 오류 발생: 현재 사용자를 담당자로 설정
        _createTodoWithAssignee(ref, originalTodo, currentUser.id!);
      },
    );
  }

  void _createTodoWithAssignee(WidgetRef ref, Todo originalTodo, int assignedTo) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentUser.id == null) return;

    // 오늘 날짜로 설정 (오늘 할일 목록에 표시되도록)
    final today = DateTime.now();
    final dueDate = DateTime(today.year, today.month, today.day, 23, 59); // 오늘 23:59

    final newTodo = Todo(
      title: originalTodo.title,
      description: originalTodo.description,
      category: originalTodo.category,
      dueDate: dueDate, // 오늘 날짜로 설정
      priority: originalTodo.priority,
      isCompleted: false,
      isRepeating: false,
      repeatType: RepeatType.none,
      createdAt: DateTime.now(),
      createdBy: currentUser.id!,
      assignedTo: assignedTo,
    );

    print('추천 할일 추가 시도: ${newTodo.title}');
    print('담당자: $assignedTo');
    print('작성자: ${currentUser.id}');
    print('dueDate: ${newTodo.dueDate}');

    ref.read(todosProvider.notifier).addTodo(newTodo);
    
    // todayTodosProvider를 invalidate하여 UI 갱신
    ref.invalidate(todayTodosProvider);
    
    // 성공 메시지 표시
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text('"${newTodo.title}"이 추가되었습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 