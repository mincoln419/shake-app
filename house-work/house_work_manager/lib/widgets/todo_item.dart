import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/todo_provider.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';
import '../screens/edit_todo_screen.dart';

class TodoItem extends ConsumerWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isMyTask = currentUser != null && todo.assignedTo == currentUser.id;
    final isCreatedByMe = currentUser != null && todo.createdBy == currentUser.id;
    
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: isMyTask
              ? (value) async {
                  try {
                    await ref.read(todosProvider.notifier).toggleTodoCompletion(todo);
                  } catch (e) {
                    // 에러 발생 시 사용자에게 알림
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('할일 상태 변경 중 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              : null,
          activeColor: const Color(AppColors.primary),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : const Color(AppColors.text),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Text(
                todo.description,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : Colors.grey[600],
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(todo.category, categories),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todo.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(todo.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(todo.priority),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isMyTask)
                  const Text('(내 담당)', style: TextStyle(color: Colors.blue, fontSize: 12)),
                if (!isMyTask)
                  const Text('(상대 담당)', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '마감: ${DateFormat('MM/dd HH:mm').format(todo.dueDate)}',
              style: TextStyle(
                color: _isOverdue(todo) ? Colors.red : Colors.grey[600],
                fontSize: 12,
                fontWeight: _isOverdue(todo) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 수정 버튼 (작성자만 수정 가능)
            if (isCreatedByMe)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _navigateToEditScreen(context),
                tooltip: '수정',
              ),
            // 작성자/담당자 표시 아이콘
            isCreatedByMe
                ? const Icon(Icons.person, color: Colors.blue)
                : const Icon(Icons.people, color: Colors.green),
          ],
        ),
        onTap: null,
        onLongPress: () {
          _showDeleteDialog(context, ref);
        },
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTodoScreen(todo: todo),
      ),
    );
  }

  Color _getCategoryColor(String categoryName, List<dynamic> categories) {
    try {
      final category = categories.firstWhere(
        (cat) => cat.name == categoryName,
      );
      return _parseColor(category.color);
    } catch (e) {
      // 기본 색상 (기존 카테고리들)
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
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF${hexColor}', radix: 16));
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppStrings.priorityLow;
      case Priority.medium:
        return AppStrings.priorityMedium;
      case Priority.high:
        return AppStrings.priorityHigh;
    }
  }

  bool _isOverdue(Todo todo) {
    return !todo.isCompleted && DateTime.now().isAfter(todo.dueDate);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할일 삭제'),
        content: Text('정말로 "${todo.title}"을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(todosProvider.notifier).deleteTodo(todo.id!);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 