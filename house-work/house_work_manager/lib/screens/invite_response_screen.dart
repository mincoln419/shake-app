import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_provider.dart';
import '../services/todo_provider.dart';
import '../models/connection.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class InviteResponseScreen extends ConsumerStatefulWidget {
  final Connection connection;
  final User inviter;

  const InviteResponseScreen({
    super.key,
    required this.connection,
    required this.inviter,
  });

  @override
  ConsumerState<InviteResponseScreen> createState() => _InviteResponseScreenState();
}

class _InviteResponseScreenState extends ConsumerState<InviteResponseScreen> {
  bool _isLoading = false;

  Future<void> _respondToInvite(ConnectionStatus status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(databaseServiceProvider).updateConnectionStatus(
        widget.connection.id!,
        status,
      );

      // 상태 새로고침
      ref.invalidate(collaborationModeProvider);
      ref.invalidate(activeConnectionProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == ConnectionStatus.accepted 
                ? '초대를 수락했습니다!' 
                : '초대를 거절했습니다.',
            ),
            backgroundColor: status == ConnectionStatus.accepted 
              ? Colors.green 
              : Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('초대 응답'),
        backgroundColor: const Color(AppColors.primary),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      // 아이콘
                      const Icon(
                        Icons.person_add,
                        size: 80,
                        color: Color(AppColors.primary),
                      ),
                      const SizedBox(height: 24),
                      // 제목
                      const Text(
                        '협업 초대',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.text),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // 초대자 정보
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.inviter.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(AppColors.text),
                              ),
                            ),
                            Text(
                              widget.inviter.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 설명
                      const Text(
                        '이 사용자가 당신과 함께 할일을 관리하고 싶어합니다.\n초대를 수락하시겠습니까?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(AppColors.text),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      // 수락 버튼
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _respondToInvite(ConnectionStatus.accepted),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                '초대 수락',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      // 거절 버튼
                      OutlinedButton(
                        onPressed: _isLoading ? null : () => _respondToInvite(ConnectionStatus.rejected),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '초대 거절',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 취소 버튼
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '나중에 결정하기',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(AppColors.text),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 