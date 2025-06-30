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
        dueDate DATETIME NOT NULL,
        isCompleted BOOLEAN DEFAULT 0,
        isRepeating BOOLEAN DEFAULT 0,
        repeatType TEXT DEFAULT 'none',
        createdBy INTEGER NOT NULL,
        assignedTo INTEGER,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        completedAt DATETIME,
        FOREIGN KEY (createdBy) REFERENCES users (id),
        FOREIGN KEY (assignedTo) REFERENCES users (id)
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
      // 기존 데이터를 보존하면서 업그레이드
      try {
        // 기존 테이블이 있는지 확인
        final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
        final tableNames = tables.map((t) => t['name'] as String).toList();
        
        if (tableNames.contains('todos')) {
          // 기존 데이터는 그대로 두고, 필요한 컬럼만 추가
          try {
            await db.execute('ALTER TABLE todos ADD COLUMN createdBy INTEGER DEFAULT 1');
          } catch (e) {
            // createdBy 컬럼이 이미 존재함
          }
          
          try {
            await db.execute('ALTER TABLE todos ADD COLUMN assignedTo INTEGER DEFAULT 1');
          } catch (e) {
            // assignedTo 컬럼이 이미 존재함
          }
        } else {
          await _onCreate(db, newVersion);
        }
      } catch (e) {
        // 오류 발생 시 안전하게 새로 생성
        await _onCreate(db, newVersion);
      }
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

  Future<List<Todo>> getAllTodos({int? userId}) async {
    final db = await database;
    
    print('=== getAllTodos 호출 ===');
    print('요청한 userId: $userId');
    
    final List<Map<String, dynamic>> maps = userId != null
        ? await db.query(
            'todos',
            where: 'createdBy = ?',  // createdBy만으로 필터링
            whereArgs: [userId],
          )
        : await db.query('todos');
    
    print('조회된 할일 개수: ${maps.length}');
    print('=== DB에서 조회한 원본 데이터 ===');
    for (var map in maps) {
      print('할일: ${map['title']}, createdBy: ${map['createdBy']}, assignedTo: ${map['assignedTo']}');
    }
    
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      
      // 데이터 타입 변환 처리 - 더 안전하게
      try {
        if (map['createdAt'] is String) {
          map['createdAt'] = DateTime.parse(map['createdAt']).millisecondsSinceEpoch;
        } else if (map['createdAt'] == null) {
          map['createdAt'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        if (map['dueDate'] is String) {
          map['dueDate'] = DateTime.parse(map['dueDate']).millisecondsSinceEpoch;
        } else if (map['dueDate'] == null) {
          map['dueDate'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        if (map['completedAt'] is String) {
          map['completedAt'] = DateTime.parse(map['completedAt']).millisecondsSinceEpoch;
        } else if (map['completedAt'] == null) {
          map['completedAt'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        // 숫자 필드들 처리
        if (map['priority'] is String) {
          map['priority'] = int.tryParse(map['priority']) ?? 1;
        }
        if (map['repeatType'] is String) {
          map['repeatType'] = int.tryParse(map['repeatType']) ?? 0;
        }
        if (map['isCompleted'] is String) {
          map['isCompleted'] = int.tryParse(map['isCompleted']) ?? 0;
        }
        if (map['isRepeating'] is String) {
          map['isRepeating'] = int.tryParse(map['isRepeating']) ?? 0;
        }
        
        // 기존 데이터 마이그레이션: createdBy, assignedTo가 없는 경우 기본값 설정
        bool wasMigrated = false;
        if (map['createdBy'] == null) {
          map['createdBy'] = userId ?? 1; // 현재 사용자 ID 또는 기본값
          wasMigrated = true;
        }
        if (map['assignedTo'] == null) {
          map['assignedTo'] = userId ?? 1; // 현재 사용자 ID 또는 기본값
          wasMigrated = true;
        }
        
        if (wasMigrated) {
          print('마이그레이션 적용됨: ${map['title']} -> createdBy: ${map['createdBy']}, assignedTo: ${map['assignedTo']}');
        }
        
        return Todo.fromMap(map);
      } catch (e) {
        rethrow;
      }
    });
  }

  Future<List<Todo>> getTodosByDate(DateTime date, {int? userId}) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    String whereClause = '''
      ((dueDate >= ? AND dueDate < ?) 
         OR (createdAt >= ? AND createdAt < ?) 
         OR (completedAt IS NOT NULL AND completedAt >= ? AND completedAt < ?))
    ''';
    
    List<dynamic> whereArgs = [
      startOfDay.millisecondsSinceEpoch, 
      endOfDay.millisecondsSinceEpoch,
      startOfDay.millisecondsSinceEpoch, 
      endOfDay.millisecondsSinceEpoch,
      startOfDay.millisecondsSinceEpoch, 
      endOfDay.millisecondsSinceEpoch,
    ];
    
    // 사용자 필터링 추가
    if (userId != null) {
      whereClause += ' AND createdBy = ?';  // createdBy만으로 필터링
      whereArgs.add(userId);
    }
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT id, title, description, category, priority, isCompleted, isRepeating, repeatType, createdAt, dueDate, completedAt, createdBy, assignedTo
      FROM todos 
      WHERE $whereClause
      ORDER BY createdAt DESC
    ''', whereArgs);
    
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      
      // 데이터 타입 변환 처리 - 더 안전하게
      try {
        if (map['createdAt'] is String) {
          map['createdAt'] = DateTime.parse(map['createdAt']).millisecondsSinceEpoch;
        } else if (map['createdAt'] == null) {
          map['createdAt'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        if (map['dueDate'] is String) {
          map['dueDate'] = DateTime.parse(map['dueDate']).millisecondsSinceEpoch;
        } else if (map['dueDate'] == null) {
          map['dueDate'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        if (map['completedAt'] is String) {
          map['completedAt'] = DateTime.parse(map['completedAt']).millisecondsSinceEpoch;
        } else if (map['completedAt'] == null) {
          map['completedAt'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        // 숫자 필드들 처리
        if (map['priority'] is String) {
          map['priority'] = int.tryParse(map['priority']) ?? 1;
        }
        if (map['repeatType'] is String) {
          map['repeatType'] = int.tryParse(map['repeatType']) ?? 0;
        }
        if (map['isCompleted'] is String) {
          map['isCompleted'] = int.tryParse(map['isCompleted']) ?? 0;
        }
        if (map['isRepeating'] is String) {
          map['isRepeating'] = int.tryParse(map['isRepeating']) ?? 0;
        }
        
        // 기존 데이터 마이그레이션: createdBy, assignedTo가 없는 경우 기본값 설정
        if (map['createdBy'] == null) {
          map['createdBy'] = userId ?? 1; // 현재 사용자 ID 또는 기본값
        }
        if (map['assignedTo'] == null) {
          map['assignedTo'] = userId ?? 1; // 현재 사용자 ID 또는 기본값
        }
        
        return Todo.fromMap(map);
      } catch (e) {
        rethrow;
      }
    });
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

  Future<List<Todo>> getRecentCompletedTodos({int limit = 5, int? userId}) async {
    final db = await database;
    
    try {
      String whereClause = 'isCompleted = 1 AND completedAt IS NOT NULL';
      List<dynamic> whereArgs = [];
      
      // 사용자 필터링 추가
      if (userId != null) {
        whereClause += ' AND createdBy = ?';  // createdBy만으로 필터링
        whereArgs.add(userId);
      }
      
      whereArgs.add(limit);
      
      // 완료된 할일 중 최근 것들을 가져오는 쿼리 (GROUP BY 제거)
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT id, title, description, category, priority, isCompleted, isRepeating, repeatType, createdAt, dueDate, completedAt, createdBy, assignedTo
        FROM todos 
        WHERE $whereClause
        ORDER BY completedAt DESC
        LIMIT ?
      ''', whereArgs);
      
      return List.generate(maps.length, (i) {
        final map = Map<String, dynamic>.from(maps[i]);
        
        // 데이터 타입 변환 처리 - 더 안전하게
        try {
          if (map['createdAt'] is String) {
            map['createdAt'] = DateTime.parse(map['createdAt']).millisecondsSinceEpoch;
          } else if (map['createdAt'] == null) {
            map['createdAt'] = DateTime.now().millisecondsSinceEpoch;
          }
          
          if (map['dueDate'] is String) {
            map['dueDate'] = DateTime.parse(map['dueDate']).millisecondsSinceEpoch;
          } else if (map['dueDate'] == null) {
            map['dueDate'] = DateTime.now().millisecondsSinceEpoch;
          }
          
          if (map['completedAt'] is String) {
            map['completedAt'] = DateTime.parse(map['completedAt']).millisecondsSinceEpoch;
          } else if (map['completedAt'] == null) {
            map['completedAt'] = DateTime.now().millisecondsSinceEpoch;
          }
          
          // 숫자 필드들 처리
          if (map['priority'] is String) {
            map['priority'] = int.tryParse(map['priority']) ?? 1;
          }
          if (map['repeatType'] is String) {
            map['repeatType'] = int.tryParse(map['repeatType']) ?? 0;
          }
          if (map['isCompleted'] is String) {
            map['isCompleted'] = int.tryParse(map['isCompleted']) ?? 0;
          }
          if (map['isRepeating'] is String) {
            map['isRepeating'] = int.tryParse(map['isRepeating']) ?? 0;
          }
          
          // 기존 데이터 마이그레이션: createdBy, assignedTo가 없는 경우 기본값 설정
          if (map['createdBy'] == null) {
            map['createdBy'] = userId ?? 1; // 현재 사용자 ID 또는 기본값
          }
          if (map['assignedTo'] == null) {
            map['assignedTo'] = userId ?? 1; // 현재 사용자 ID 또는 기본값
          }
          
          return Todo.fromMap(map);
        } catch (e) {
          rethrow;
        }
      });
    } catch (e) {
      return [];
    }
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

  // 테스트용 완료된 할일 추가
  Future<void> addTestCompletedTodo() async {
    final db = await database;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    await db.insert('todos', {
      'title': '테스트 완료된 할일',
      'description': '테스트용 완료된 할일입니다',
      'category': '청소',
      'dueDate': yesterday.millisecondsSinceEpoch,
      'priority': 1,
      'isCompleted': 1,
      'isRepeating': 0,
      'repeatType': 0,
      'createdAt': yesterday.millisecondsSinceEpoch,
      'completedAt': now.millisecondsSinceEpoch,
      'createdBy': 1,
      'assignedTo': 1,
    });
  }

  Future<List<Todo>> getCollaborativeTodos({required int userId, required int partnerId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: '(createdBy = ? OR createdBy = ? OR assignedTo = ? OR assignedTo = ?)',
      whereArgs: [userId, partnerId, userId, partnerId],
    );
    
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      
      // 데이터 타입 변환 처리 - 더 안전하게
      try {
        if (map['createdAt'] is String) {
          map['createdAt'] = DateTime.parse(map['createdAt']).millisecondsSinceEpoch;
        } else if (map['createdAt'] == null) {
          map['createdAt'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        if (map['dueDate'] is String) {
          map['dueDate'] = DateTime.parse(map['dueDate']).millisecondsSinceEpoch;
        } else if (map['dueDate'] == null) {
          map['dueDate'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        if (map['completedAt'] is String) {
          map['completedAt'] = DateTime.parse(map['completedAt']).millisecondsSinceEpoch;
        } else if (map['completedAt'] == null) {
          map['completedAt'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        // 숫자 필드들 처리
        if (map['priority'] is String) {
          map['priority'] = int.tryParse(map['priority']) ?? 1;
        }
        if (map['repeatType'] is String) {
          map['repeatType'] = int.tryParse(map['repeatType']) ?? 0;
        }
        if (map['isCompleted'] is String) {
          map['isCompleted'] = int.tryParse(map['isCompleted']) ?? 0;
        }
        if (map['isRepeating'] is String) {
          map['isRepeating'] = int.tryParse(map['isRepeating']) ?? 0;
        }
        
        // 기존 데이터 마이그레이션: createdBy, assignedTo가 없는 경우 기본값 설정
        if (map['createdBy'] == null) {
          map['createdBy'] = userId; // 현재 사용자 ID
        }
        if (map['assignedTo'] == null) {
          map['assignedTo'] = userId; // 현재 사용자 ID
        }
        
        return Todo.fromMap(map);
      } catch (e) {
        rethrow;
      }
    });
  }

  Future<List<Todo>> getCollaborativeTodosByDate(DateTime date, {required int userId, required int partnerId}) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT id, title, description, category, priority, isCompleted, isRepeating, repeatType, createdAt, dueDate, completedAt, createdBy, assignedTo
      FROM todos 
      WHERE ((dueDate >= ? AND dueDate < ?) 
         OR (createdAt >= ? AND createdAt < ?) 
         OR (completedAt IS NOT NULL AND completedAt >= ? AND completedAt < ?))
         AND (createdBy = ? OR createdBy = ? OR assignedTo = ? OR assignedTo = ?)
      ORDER BY createdAt DESC
    ''', [
      startOfDay.millisecondsSinceEpoch, 
      endOfDay.millisecondsSinceEpoch,
      startOfDay.millisecondsSinceEpoch, 
      endOfDay.millisecondsSinceEpoch,
      startOfDay.millisecondsSinceEpoch, 
      endOfDay.millisecondsSinceEpoch,
      userId, partnerId, userId, partnerId,
    ]);
    
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      
      // 데이터 타입 변환 처리 - 더 안전하게
      try {
        if (map['createdAt'] is String) {
          map['createdAt'] = DateTime.parse(map['createdAt']).millisecondsSinceEpoch;
        } else if (map['createdAt'] == null) {
          map['createdAt'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        if (map['dueDate'] is String) {
          map['dueDate'] = DateTime.parse(map['dueDate']).millisecondsSinceEpoch;
        } else if (map['dueDate'] == null) {
          map['dueDate'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        if (map['completedAt'] is String) {
          map['completedAt'] = DateTime.parse(map['completedAt']).millisecondsSinceEpoch;
        } else if (map['completedAt'] == null) {
          map['completedAt'] = DateTime.now().millisecondsSinceEpoch;
        }
        
        // 숫자 필드들 처리
        if (map['priority'] is String) {
          map['priority'] = int.tryParse(map['priority']) ?? 1;
        }
        if (map['repeatType'] is String) {
          map['repeatType'] = int.tryParse(map['repeatType']) ?? 0;
        }
        if (map['isCompleted'] is String) {
          map['isCompleted'] = int.tryParse(map['isCompleted']) ?? 0;
        }
        if (map['isRepeating'] is String) {
          map['isRepeating'] = int.tryParse(map['isRepeating']) ?? 0;
        }
        
        // 기존 데이터 마이그레이션: createdBy, assignedTo가 없는 경우 기본값 설정
        if (map['createdBy'] == null) {
          map['createdBy'] = userId; // 현재 사용자 ID
        }
        if (map['assignedTo'] == null) {
          map['assignedTo'] = userId; // 현재 사용자 ID
        }
        
        return Todo.fromMap(map);
      } catch (e) {
        rethrow;
      }
    });
  }

  // 기존 데이터 정리 메서드 (디버깅용)
  Future<void> cleanupOldData() async {
    final db = await database;
    
    print('=== 기존 데이터 정리 시작 ===');
    
    // 모든 할일 조회
    final allTodos = await db.query('todos');
    print('전체 할일 개수: ${allTodos.length}');
    
    for (var todo in allTodos) {
      print('할일: ${todo['title']}, createdBy: ${todo['createdBy']}, assignedTo: ${todo['assignedTo']}');
    }
    
    // createdBy나 assignedTo가 null인 데이터 삭제 (테스트용)
    final deletedCount = await db.delete(
      'todos',
      where: 'createdBy IS NULL OR assignedTo IS NULL',
    );
    
    print('삭제된 할일 개수: $deletedCount');
    print('=== 기존 데이터 정리 완료 ===');
  }

  // 데이터베이스 완전 초기화 (디버깅용)
  Future<void> resetDatabase() async {
    final db = await database;
    
    print('=== 데이터베이스 초기화 시작 ===');
    
    // 모든 테이블 삭제
    await db.execute('DROP TABLE IF EXISTS todos');
    await db.execute('DROP TABLE IF EXISTS categories');
    await db.execute('DROP TABLE IF EXISTS history');
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS connections');
    
    print('모든 테이블 삭제 완료');
    
    // 테이블 다시 생성
    await _onCreate(db, 3);
    
    print('테이블 재생성 완료');
    print('=== 데이터베이스 초기화 완료 ===');
  }

  // 모든 할일 조회 (디버깅용)
  Future<void> debugAllTodos() async {
    final db = await database;
    
    print('=== 모든 할일 조회 (디버깅용) ===');
    
    final allTodos = await db.query('todos');
    print('전체 할일 개수: ${allTodos.length}');
    
    for (var todo in allTodos) {
      print('할일: ${todo['title']}, createdBy: ${todo['createdBy']}, assignedTo: ${todo['assignedTo']}');
    }
    
    // 사용자 정보도 함께 조회
    final allUsers = await db.query('users');
    print('전체 사용자 개수: ${allUsers.length}');
    
    for (var user in allUsers) {
      print('사용자: ${user['email']}, id: ${user['id']}');
    }
    
    print('=== 디버깅 완료 ===');
  }
} 