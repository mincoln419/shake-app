import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';
import '../models/history.dart';
import '../models/category.dart';
import '../models/user.dart';
import '../models/connection.dart';
import '../models/collaboration_mode.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'house_work_manager.db');
    
    // 기존 데이터베이스 파일 삭제 (개발 중에만 사용)
    try {
      await deleteDatabase(path);
      print('기존 데이터베이스 파일을 삭제했습니다.');
    } catch (e) {
      print('데이터베이스 파일 삭제 중 오류: $e');
    }
    
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 사용자 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        avatar TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 연결 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS connections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user1_id INTEGER NOT NULL,
        user2_id INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user1_id) REFERENCES users (id),
        FOREIGN KEY (user2_id) REFERENCES users (id)
      )
    ''');

    // 할일 테이블 (확장)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        priority TEXT DEFAULT 'normal',
        due_date DATETIME NOT NULL,
        is_completed BOOLEAN DEFAULT 0,
        is_repeating BOOLEAN DEFAULT 0,
        repeat_type TEXT DEFAULT 'none',
        created_by INTEGER NOT NULL,
        assigned_to INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        completed_at DATETIME,
        FOREIGN KEY (created_by) REFERENCES users (id),
        FOREIGN KEY (assigned_to) REFERENCES users (id)
      )
    ''');

    // 이력 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todoId INTEGER NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        completedAt INTEGER NOT NULL,
        completionTime INTEGER NOT NULL,
        FOREIGN KEY (todoId) REFERENCES todos (id)
      )
    ''');

    // 카테고리 테이블
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        color TEXT DEFAULT '#2196F3',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 기본 카테고리 추가
    await db.execute('''
      INSERT OR IGNORE INTO categories (name, color) VALUES 
      ('요리', '#FF9800'),
      ('청소', '#2196F3'),
      ('빨래', '#4CAF50'),
      ('쇼핑', '#9C27B0')
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // 모든 테이블을 다시 생성
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': '요리', 'color': '#FF9800'},
      {'name': '청소', 'color': '#2196F3'},
      {'name': '빨래', 'color': '#4CAF50'},
      {'name': '쇼핑', 'color': '#9C27B0'},
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', {
        'name': category['name'],
        'color': category['color'],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Todo CRUD 작업
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      final map = maps[i];
      // 기존 데이터 마이그레이션: createdBy, assignedTo가 없는 경우 기본값 설정
      if (map['created_by'] == null) {
        map['created_by'] = 1; // 기본 사용자 ID
      }
      if (map['assigned_to'] == null) {
        map['assigned_to'] = 1; // 기본 사용자 ID
      }
      return Todo.fromMap(map);
    });
  }

  Future<List<Todo>> getTodosByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'dueDate >= ? AND dueDate < ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<int> updateTodo(Todo todo) async {
    try {
      final db = await database;
      return await db.update(
        'todos',
        todo.toMap(),
        where: 'id = ?',
        whereArgs: [todo.id],
      );
    } catch (e) {
      print('할일 업데이트 중 오류 발생: $e');
      print('할일 데이터: ${todo.toMap()}');
      rethrow;
    }
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // History CRUD 작업
  Future<int> insertHistory(History history) async {
    final db = await database;
    return await db.insert('history', history.toMap());
  }

  Future<List<History>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      orderBy: 'completedAt DESC',
    );
    return List.generate(maps.length, (i) => History.fromMap(maps[i]));
  }

  Future<List<History>> getHistoryByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'completedAt >= ? AND completedAt <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'completedAt DESC',
    );
    return List.generate(maps.length, (i) => History.fromMap(maps[i]));
  }

  Future<int> deleteHistory(int id) async {
    final db = await database;
    return await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category CRUD 작업
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> categoryExists(String name) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }

  // 통계 쿼리
  Future<Map<String, int>> getCategoryStats(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM history
      WHERE completedAt >= ? AND completedAt <= ?
      GROUP BY category
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    Map<String, int> stats = {};
    for (var map in maps) {
      stats[map['category']] = map['count'];
    }
    return stats;
  }

  Future<int> getCompletionRate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as total
      FROM todos
      WHERE dueDate >= ? AND dueDate < ?
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    
    final completedResult = await db.rawQuery('''
      SELECT COUNT(*) as completed
      FROM todos
      WHERE dueDate >= ? AND dueDate < ? AND isCompleted = 1
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    
    final total = totalResult.first['total'] as int;
    final completed = completedResult.first['completed'] as int;
    
    return total > 0 ? ((completed / total) * 100).round() : 0;
  }

  Future<List<Todo>> getRecentCompletedTodos({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT title, description, category, priority, is_completed, is_repeating, repeat_type, created_at, due_date, completed_at, created_by, assigned_to
      FROM todos 
      WHERE is_completed = 1 AND is_repeating = 0
      GROUP BY title
      ORDER BY MAX(completed_at) DESC
      LIMIT ?
    ''', [limit]);
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // 테스트용 임시 메서드 - 기존 데이터들의 날짜를 어제로 변경
  Future<void> updateDatesForTesting() async {
    final db = await database;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayString = yesterday.toIso8601String();
    
    await db.update(
      'todos',
      {
        'createdAt': yesterdayString,
        'dueDate': yesterdayString,
      },
      where: '1=1', // 모든 레코드 업데이트
    );
    
    print('모든 할일의 날짜가 어제(${yesterday.toString()})로 변경되었습니다.');
  }

  // 사용자 관리 메서드들
  Future<User> createUser(String name, String email, {String? avatar}) async {
    final db = await database;
    final id = await db.insert('users', {
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': DateTime.now().toIso8601String(),
    });
    return User(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      createdAt: DateTime.now(),
    );
  }

  Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // 연결 관리 메서드들
  Future<Connection> createConnection(int user1Id, int user2Id) async {
    final db = await database;
    final id = await db.insert('connections', {
      'user1_id': user1Id,
      'user2_id': user2Id,
      'status': ConnectionStatus.pending.name,
      'created_at': DateTime.now().toIso8601String(),
    });
    return Connection(
      id: id,
      user1Id: user1Id,
      user2Id: user2Id,
      status: ConnectionStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  Future<List<Connection>> getConnections(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'connections',
      where: 'user1_id = ? OR user2_id = ?',
      whereArgs: [userId, userId],
    );
    return List.generate(maps.length, (i) => Connection.fromMap(maps[i]));
  }

  Future<Connection?> getActiveConnection(int userId) async {
    final connections = await getConnections(userId);
    return connections.where((c) => c.status == ConnectionStatus.accepted).firstOrNull;
  }

  Future<Connection?> getPendingConnection(int userId) async {
    final connections = await getConnections(userId);
    return connections.where((c) => c.status == ConnectionStatus.pending).firstOrNull;
  }

  Future<void> updateConnectionStatus(int connectionId, ConnectionStatus status) async {
    final db = await database;
    await db.update(
      'connections',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [connectionId],
    );
  }

  // 협업 모드 확인
  Future<CollaborationMode> getCollaborationMode(int userId) async {
    final connections = await getConnections(userId);
    
    if (connections.isEmpty) {
      return CollaborationMode.personal;
    }
    
    final activeConnection = connections.where((c) => c.status == ConnectionStatus.accepted).firstOrNull;
    if (activeConnection != null) {
      return CollaborationMode.connected;
    }
    
    final pendingConnection = connections.where((c) => c.status == ConnectionStatus.pending).firstOrNull;
    if (pendingConnection != null) {
      return CollaborationMode.pending;
    }
    
    return CollaborationMode.personal;
  }
} 