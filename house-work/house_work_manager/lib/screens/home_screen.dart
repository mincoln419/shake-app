import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/todo_provider.dart';
import '../services/user_provider.dart';
import '../models/collaboration_mode.dart';
import '../models/connection.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../widgets/todo_item.dart';
import '../widgets/recent_todos_suggestions.dart';
import 'add_todo_screen.dart';
import 'history_screen.dart';
import 'statistics_screen.dart';
import 'invite_screen.dart';
import 'invite_response_screen.dart';
import 'login_screen.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTodos = ref.watch(todosProvider);
    final collaborationMode = ref.watch(collaborationModeProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    final today = DateTime.now();
    final todayTodos = allTodos.where((todo) {
      final todoDate = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      return todoDate.isAtSameMomentAs(todayDate);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(currentUserProvider.notifier).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          // 테스트용 임시 버튼
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () async {
              await ref.read(databaseServiceProvider).updateDatesForTesting();
              // 상태 새로고침
              ref.invalidate(todosProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
      body: collaborationMode.when(
        data: (mode) => _buildBody(context, ref, mode, todayTodos),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoScreen()),
          );
          if (result == true) {
            // 할일이 추가되면 자동으로 상태가 업데이트됩니다
          }
        },
        backgroundColor: const Color(AppColors.primary),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CollaborationMode mode, List todayTodos) {
    return Column(
      children: [
        // 상단 헤더
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.text),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오늘의 완료율: ',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(AppColors.text),
                    ),
                  ),
                  Text(
                    '${_calculateCompletionRate(todayTodos)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primary),
                    ),
                  ),
                  Text(
                    ' (${todayTodos.where((todo) => todo.isCompleted).length}/${todayTodos.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(AppColors.text),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 협업 모드 상태 표시
        _buildCollaborationStatus(context, ref, mode),
        
        // 할일 관련 UI 표시 조건 확인
        Expanded(
          child: Builder(
            builder: (context) {
              // pending 상태일 때 초대받은 사람인지 확인
              if (mode == CollaborationMode.pending) {
                return FutureBuilder<Connection?>(
                  future: ref.read(pendingConnectionProvider.future),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final connection = snapshot.data;
                    if (connection == null) {
                      // 연결 정보가 없으면 할일 목록 표시
                      return _buildTodoContent(context, ref, todayTodos, mode);
                    }

                    // 현재 사용자가 초대받은 사람인지 확인
                    final currentUser = ref.read(currentUserProvider);
                    final isInvitee = connection.user2Id == currentUser?.id;

                    if (isInvitee) {
                      // 초대받은 사람: 할일 목록 숨김
                      return const SizedBox();
                    } else {
                      // 초대한 사람: 자신의 할일 목록 표시
                      return _buildTodoContent(context, ref, todayTodos, mode);
                    }
                  },
                );
              } else {
                // pending 상태가 아니면 항상 할일 목록 표시
                return _buildTodoContent(context, ref, todayTodos, mode);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodoContent(BuildContext context, WidgetRef ref, List todayTodos, CollaborationMode mode) {
    return Column(
      children: [
        // 추천 할일 섹션
        RecentTodosSuggestions(
          onTodoSelected: (todo) {
            // 할일이 추가되면 자동으로 상태가 업데이트됩니다
          },
        ),
        
        // 할일 목록
        Expanded(
          child: todayTodos.isEmpty
              ? _buildEmptyState(context, ref, mode)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: todayTodos.length,
                  itemBuilder: (context, index) {
                    final todo = todayTodos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TodoItem(todo: todo),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCollaborationStatus(BuildContext context, WidgetRef ref, CollaborationMode mode) {
    switch (mode) {
      case CollaborationMode.personal:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.person,
                color: Colors.blue,
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                '개인 모드',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '협업 기능을 사용하려면 상대방을 초대해보세요!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InviteScreen()),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('초대하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
        
      case CollaborationMode.pending:
        return FutureBuilder<Connection?>(
          future: ref.read(pendingConnectionProvider.future),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final connection = snapshot.data;
            if (connection == null) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.orange,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '초대 대기 중',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '상대방이 초대를 수락할 때까지 기다리는 중입니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // 현재 사용자가 초대받은 사람인지 확인
            final currentUser = ref.read(currentUserProvider);
            final isInvitee = connection.user2Id == currentUser?.id;

            if (isInvitee) {
              // 초대받은 사람: 초대를 수락할 수 있는 버튼 표시
              return FutureBuilder<User?>(
                future: ref.read(databaseServiceProvider).getUser(connection.user1Id),
                builder: (context, inviterSnapshot) {
                  if (inviterSnapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  final inviter = inviterSnapshot.data;
                  if (inviter == null) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.orange,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '초대자 정보를 찾을 수 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_add,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '초대 받음',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${inviter.name}님이 협업을 요청했습니다.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InviteResponseScreen(
                                  connection: connection,
                                  inviter: inviter,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('초대 응답하기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              // 초대한 사람: 대기 중 메시지 표시
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.orange,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '초대 대기 중',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '상대방이 초대를 수락할 때까지 기다리는 중입니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
          },
        );
        
      case CollaborationMode.connected:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.people,
                color: Colors.green,
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                '협업 모드',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '상대방과 함께 할일을 관리하고 있습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, CollaborationMode mode) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Color(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            '오늘의 할일이 없습니다!',
            style: TextStyle(
              fontSize: 18,
              color: Color(AppColors.text),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '새로운 할일을 추가해보세요.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCompletionRate(List<dynamic> todos) {
    if (todos.isEmpty) return 0;
    final completedCount = todos.where((todo) => todo.isCompleted).length;
    return ((completedCount / todos.length) * 100).round();
  }
} 