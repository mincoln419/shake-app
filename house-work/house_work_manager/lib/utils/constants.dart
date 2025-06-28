enum Priority {
  low,
  medium,
  high,
}

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
}

class AppColors {
  static const int primary = 0xFF4A90E2;
  static const int secondary = 0xFFF5A623;
  static const int success = 0xFF7ED321;
  static const int background = 0xFFF8F9FA;
  static const int text = 0xFF333333;
}

class AppStrings {
  static const String appTitle = 'HouseWork Manager';
  static const String addTodo = '할일 추가';
  static const String editTodo = '할일 수정';
  static const String deleteTodo = '할일 삭제';
  static const String completeTodo = '완료';
  static const String incompleteTodo = '미완료';
  
  // 카테고리
  static const String categoryCooking = '요리';
  static const String categoryCleaning = '청소';
  static const String categoryLaundry = '빨래';
  static const String categoryShopping = '쇼핑';
  static const String categoryOther = '기타';
  
  // 우선순위
  static const String priorityLow = '낮음';
  static const String priorityMedium = '보통';
  static const String priorityHigh = '긴급';
} 