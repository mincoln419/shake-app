class History {
  final int? id;
  final int todoId;
  final String title;
  final String category;
  final DateTime completedAt;
  final int completionTime; // 완료까지 걸린 시간(분)

  History({
    this.id,
    required this.todoId,
    required this.title,
    required this.category,
    required this.completedAt,
    required this.completionTime,
  });

  History copyWith({
    int? id,
    int? todoId,
    String? title,
    String? category,
    DateTime? completedAt,
    int? completionTime,
  }) {
    return History(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      title: title ?? this.title,
      category: category ?? this.category,
      completedAt: completedAt ?? this.completedAt,
      completionTime: completionTime ?? this.completionTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoId': todoId,
      'title': title,
      'category': category,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'completionTime': completionTime,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],
      todoId: map['todoId'],
      title: map['title'],
      category: map['category'],
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt']),
      completionTime: map['completionTime'],
    );
  }

  @override
  String toString() {
    return 'History(id: $id, title: $title, category: $category, completedAt: $completedAt)';
  }
} 