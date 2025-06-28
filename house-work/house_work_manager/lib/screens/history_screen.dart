import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/todo_provider.dart';
import '../utils/constants.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('완료 이력'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final historyList = ref.watch(historyProvider);
          
          if (historyList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Color(AppColors.primary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '완료된 할일이 없습니다!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(AppColors.text),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '할일을 완료하면 여기에 기록됩니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // 날짜별로 그룹화
          final groupedHistory = <String, List<dynamic>>{};
          for (final history in historyList) {
            final dateKey = DateFormat('yyyy년 MM월 dd일').format(history.completedAt);
            if (!groupedHistory.containsKey(dateKey)) {
              groupedHistory[dateKey] = [];
            }
            groupedHistory[dateKey]!.add(history);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedHistory.length,
            itemBuilder: (context, index) {
              final dateKey = groupedHistory.keys.elementAt(index);
              final histories = groupedHistory[dateKey]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      dateKey,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primary),
                      ),
                    ),
                  ),
                  ...histories.map((history) => _buildHistoryItem(context, ref, history)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, WidgetRef ref, dynamic history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getCategoryColor(history.category),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          history.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(AppColors.text),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getCategoryColor(history.category),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                history.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '완료 시간: ${DateFormat('HH:mm').format(history.completedAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (history.completionTime > 0)
              Text(
                '소요 시간: ${history.completionTime}분',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(context, ref, history);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('삭제', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case AppStrings.categoryCooking:
        return Colors.orange;
      case AppStrings.categoryCleaning:
        return Colors.blue;
      case AppStrings.categoryLaundry:
        return Colors.green;
      case AppStrings.categoryShopping:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이력 삭제'),
        content: Text('정말로 "${history.title}"의 완료 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).deleteHistory(history.id);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 