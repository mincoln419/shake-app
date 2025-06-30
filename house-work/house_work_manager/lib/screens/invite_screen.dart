import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_provider.dart';
import '../services/todo_provider.dart';
import '../utils/constants.dart';

class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        _showError('사용자 정보를 찾을 수 없습니다.');
        return;
      }

      final email = _emailController.text.trim();
      
      // 이메일 형식 검증
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _showError('올바른 이메일 주소를 입력해주세요.');
        return;
      }

      // 자기 자신에게 초대 보내기 방지
      if (email == currentUser.email) {
        _showError('자기 자신에게는 초대를 보낼 수 없습니다.');
        return;
      }

      // 상대방 사용자 찾기 또는 생성
      var targetUser = await ref.read(databaseServiceProvider).getUserByEmail(email);
      if (targetUser == null) {
        // 임시 테스트용 사용자 자동 생성
        targetUser = await ref.read(databaseServiceProvider).createUser(
          '상대방',
          email,
        );
      }

      // 연결 생성
      await ref.read(databaseServiceProvider).createConnection(
        currentUser.id!,
        targetUser.id!,
      );

      // 상태 새로고침
      ref.invalidate(collaborationModeProvider);
      ref.invalidate(activeConnectionProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('초대가 성공적으로 전송되었습니다!'),
            backgroundColor: Color(AppColors.primary),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('초대 전송 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상대방 초대'),
        backgroundColor: const Color(AppColors.primary),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                '함께 할 상대방을 초대하세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.text),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // 설명
              const Text(
                '이메일 주소를 입력하면 상대방에게 초대를 보낼 수 있습니다.\n초대가 수락되면 함께 할일을 관리할 수 있습니다.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(AppColors.text),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // 이메일 입력 필드
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '이메일 주소',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일 주소를 입력해주세요';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return '올바른 이메일 주소를 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // 초대 보내기 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : _sendInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primary),
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
                        '초대 보내기',
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
                  '취소',
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
  }
} 