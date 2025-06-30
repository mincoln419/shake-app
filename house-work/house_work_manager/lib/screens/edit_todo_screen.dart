import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../models/category.dart';
import '../services/todo_provider.dart';
import '../services/user_provider.dart';
import '../models/collaboration_mode.dart';
import '../models/connection.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../widgets/add_category_dialog.dart';

class EditTodoScreen extends ConsumerStatefulWidget {
  final Todo todo;

  const EditTodoScreen({
    super.key,
    required this.todo,
  });

  @override
  ConsumerState<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends ConsumerState<EditTodoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  late Priority _selectedPriority;
  late bool _isRepeating;
  late RepeatType _repeatType;
  late int? _assignedTo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    _selectedCategory = widget.todo.category;
    _selectedDate = widget.todo.dueDate;
    _selectedPriority = widget.todo.priority;
    _isRepeating = widget.todo.isRepeating;
    _repeatType = widget.todo.repeatType;
    _assignedTo = widget.todo.assignedTo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할일 수정'),
        backgroundColor: const Color(AppColors.primary),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '할일 제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 설명 입력
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '설명 (선택사항)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 카테고리 선택
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: '요리', child: Text('요리')),
                DropdownMenuItem(value: '청소', child: Text('청소')),
                DropdownMenuItem(value: '빨래', child: Text('빨래')),
                DropdownMenuItem(value: '쇼핑', child: Text('쇼핑')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 날짜 선택
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '마감일',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 우선순위 선택
            DropdownButtonFormField<Priority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: '우선순위',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_getPriorityText(priority)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 반복 설정
            CheckboxListTile(
              title: const Text('반복'),
              value: _isRepeating,
              onChanged: (value) {
                setState(() {
                  _isRepeating = value!;
                });
              },
            ),
            if (_isRepeating) ...[
              DropdownButtonFormField<RepeatType>(
                value: _repeatType,
                decoration: const InputDecoration(
                  labelText: '반복 주기',
                  border: OutlineInputBorder(),
                ),
                items: RepeatType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getRepeatTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _repeatType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // 협업 모드에서 담당자 선택
            Consumer(
              builder: (context, ref, child) {
                final collaborationMode = ref.watch(collaborationModeProvider);
                
                return collaborationMode.when(
                  data: (mode) {
                    if (mode == CollaborationMode.connected) {
                      return _buildAssigneeSelection();
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                );
              },
            ),

            const SizedBox(height: 32),

            // 수정 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primary),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '수정하기',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssigneeSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final currentUser = ref.read(currentUserProvider);
        
        return ref.watch(activeConnectionProvider).when(
          data: (connection) {
            if (connection == null) return const SizedBox.shrink();
            
            final partnerId = connection.user1Id == currentUser?.id 
                ? connection.user2Id 
                : connection.user1Id;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '담당자',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('나'),
                        value: currentUser?.id ?? 1,
                        groupValue: _assignedTo,
                        onChanged: (value) {
                          setState(() {
                            _assignedTo = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('상대방'),
                        value: partnerId,
                        groupValue: _assignedTo,
                        onChanged: (value) {
                          setState(() {
                            _assignedTo = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return '낮음';
      case Priority.medium:
        return '보통';
      case Priority.high:
        return '높음';
    }
  }

  String _getRepeatTypeText(RepeatType type) {
    switch (type) {
      case RepeatType.none:
        return '반복 안함';
      case RepeatType.daily:
        return '매일';
      case RepeatType.weekly:
        return '매주';
      case RepeatType.monthly:
        return '매월';
    }
  }

  void _updateTodo() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('할일 제목을 입력해주세요')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다')),
      );
      return;
    }

    final updatedTodo = widget.todo.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      dueDate: _selectedDate,
      priority: _selectedPriority,
      isRepeating: _isRepeating,
      repeatType: _repeatType,
      assignedTo: _assignedTo,
    );

    try {
      await ref.read(todosProvider.notifier).updateTodo(updatedTodo);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('할일이 수정되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('할일 수정 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
} 