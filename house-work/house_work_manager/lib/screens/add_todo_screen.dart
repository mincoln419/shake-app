import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../models/collaboration_mode.dart';
import '../services/todo_provider.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/add_category_dialog.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  const AddTodoScreen({super.key});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = '';
  Priority _selectedPriority = Priority.medium;
  bool _isRepeating = false;
  RepeatType _repeatType = RepeatType.none;
  int? _assignedTo; // 담당자 id

  @override
  void initState() {
    super.initState();
    // 기본 카테고리 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = ref.read(categoriesProvider);
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categories.first.name;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final currentUser = ref.watch(currentUserProvider);
    final collaborationModeAsync = ref.watch(collaborationModeProvider);
    final activeConnectionAsync = ref.watch(activeConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('새 할일 추가'),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '할일 제목',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 설명 입력
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택사항)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // 카테고리 선택
              DropdownButtonFormField<String>(
                value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                decoration: const InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                ),
                items: [
                  ...categories.map((category) {
                    return DropdownMenuItem(
                      value: category.name,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _parseColor(category.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  const DropdownMenuItem(
                    value: 'add_new',
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 8),
                        Text('새 카테고리 추가'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == 'add_new') {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const AddCategoryDialog(),
                    );
                    if (result == true) {
                      // 카테고리가 추가되면 상태가 자동으로 업데이트됩니다
                      final updatedCategories = ref.read(categoriesProvider);
                      if (updatedCategories.isNotEmpty) {
                        setState(() {
                          _selectedCategory = updatedCategories.last.name;
                        });
                      }
                    }
                  } else if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
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

              // 날짜 선택
              ListTile(
                title: const Text('마감 날짜'),
                subtitle: Text(
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 8),

              // 시간 선택
              ListTile(
                title: const Text('마감 시간'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),
              const SizedBox(height: 16),

              // 반복 설정
              SwitchListTile(
                title: const Text('반복'),
                subtitle: const Text('할일을 반복적으로 설정'),
                value: _isRepeating,
                onChanged: (value) {
                  setState(() {
                    _isRepeating = value;
                    if (value) {
                      _repeatType = RepeatType.daily;
                    } else {
                      _repeatType = RepeatType.none;
                    }
                  });
                },
              ),
              if (_isRepeating) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<RepeatType>(
                  value: _repeatType,
                  decoration: const InputDecoration(
                    labelText: '반복 주기',
                    border: OutlineInputBorder(),
                  ),
                  items: RepeatType.values.where((type) => type != RepeatType.none).map((type) {
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
              ],

              // 담당자 선택
              collaborationModeAsync.when(
                data: (mode) {
                  if (mode == CollaborationMode.connected && activeConnectionAsync.value != null && currentUser != null) {
                    final connection = activeConnectionAsync.value!;
                    final isUser1 = connection.user1Id == currentUser.id;
                    final partnerId = isUser1 ? connection.user2Id : connection.user1Id;
                    return DropdownButtonFormField<int>(
                      value: _assignedTo ?? currentUser.id,
                      decoration: const InputDecoration(
                        labelText: '담당자',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: currentUser.id,
                          child: const Text('나'),
                        ),
                        DropdownMenuItem(
                          value: partnerId,
                          child: const Text('상대방'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _assignedTo = value;
                        });
                      },
                    );
                  } else if (currentUser != null) {
                    // 개인 모드: 나만 선택 가능
                    _assignedTo = currentUser.id;
                    return DropdownButtonFormField<int>(
                      value: currentUser.id,
                      decoration: const InputDecoration(
                        labelText: '담당자',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: currentUser.id,
                          child: const Text('나'),
                        ),
                      ],
                      onChanged: null,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF${hexColor}', radix: 16));
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTodo() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final todo = Todo(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      dueDate: _selectedDate,
      priority: _selectedPriority,
      isCompleted: false,
      isRepeating: _isRepeating,
      repeatType: _repeatType,
      createdAt: DateTime.now(),
      createdBy: currentUser.id!,
      assignedTo: _assignedTo ?? currentUser.id!,
    );

    ref.read(todosProvider.notifier).addTodo(todo);
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('할일이 추가되었습니다')),
    );
  }
} 