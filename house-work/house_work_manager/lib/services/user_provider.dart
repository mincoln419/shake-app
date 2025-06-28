import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/connection.dart';
import '../models/collaboration_mode.dart';
import 'database_service.dart';
import 'todo_provider.dart';

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier(ref.read(databaseServiceProvider));
});

final collaborationModeProvider = FutureProvider<CollaborationMode>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return CollaborationMode.personal;
  
  final db = ref.read(databaseServiceProvider);
  return await db.getCollaborationMode(currentUser.id!);
});

final activeConnectionProvider = FutureProvider<Connection?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;
  
  final db = ref.read(databaseServiceProvider);
  return await db.getActiveConnection(currentUser.id!);
});

final pendingConnectionProvider = FutureProvider<Connection?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;
  
  final db = ref.read(databaseServiceProvider);
  return await db.getPendingConnection(currentUser.id!);
});

class CurrentUserNotifier extends StateNotifier<User?> {
  final DatabaseService _databaseService;

  CurrentUserNotifier(this._databaseService) : super(null);

  Future<void> updateUser(User user) async {
    await _databaseService.updateUser(user);
    state = user;
  }

  Future<void> updateProfile(String name, String? avatar) async {
    if (state != null) {
      final updatedUser = state!.copyWith(
        name: name,
        avatar: avatar,
      );
      await updateUser(updatedUser);
    }
  }

  void logout() {
    state = null;
  }
} 