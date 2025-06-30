enum ConnectionStatus {
  pending,
  accepted,
  rejected,
}

class Connection {
  final int? id;
  final int user1Id;
  final int user2Id;
  final ConnectionStatus status;
  final DateTime createdAt;

  Connection({
    this.id,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Connection.fromMap(Map<String, dynamic> map) {
    return Connection(
      id: map['id'],
      user1Id: map['user1_id'],
      user2Id: map['user2_id'],
      status: ConnectionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Connection copyWith({
    int? id,
    int? user1Id,
    int? user2Id,
    ConnectionStatus? status,
    DateTime? createdAt,
  }) {
    return Connection(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 