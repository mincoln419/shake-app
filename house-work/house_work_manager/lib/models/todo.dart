import '../utils/constants.dart';

class Todo {
  final int? id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;
  final bool isRepeating;
  final RepeatType repeatType;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? assignedTo;
  final int? createdBy;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.isRepeating = false,
    this.repeatType = RepeatType.none,
    required this.createdAt,
    this.completedAt,
    this.assignedTo,
    this.createdBy,
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    bool? isRepeating,
    RepeatType? repeatType,
    DateTime? createdAt,
    DateTime? completedAt,
    int? assignedTo,
    int? createdBy,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatType: repeatType ?? this.repeatType,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'priority': priority.index,
      'isCompleted': isCompleted ? 1 : 0,
      'isRepeating': isRepeating ? 1 : 0,
      'repeatType': repeatType.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      dueDate: map['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : DateTime.now(),
      priority: map['priority'] != null 
          ? Priority.values[map['priority']]
          : Priority.medium,
      isCompleted: map['isCompleted'] == 1,
      isRepeating: map['isRepeating'] == 1,
      repeatType: map['repeatType'] != null 
          ? RepeatType.values[map['repeatType']]
          : RepeatType.none,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      assignedTo: map['assignedTo'],
      createdBy: map['createdBy'],
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, category: $category, isCompleted: $isCompleted)';
  }
} 