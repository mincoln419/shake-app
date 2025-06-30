import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/todo_provider.dart';
import '../utils/constants.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedPeriod = '이번 주';
  final List<String> _periods = ['오늘', '이번 주', '이번 달'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Text(period),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompletionRateCard(),
            const SizedBox(height: 16),
            _buildCategoryStatsCard(),
            const SizedBox(height: 16),
            _buildRecentActivityCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '완료율',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.text),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<int>(
              future: _getCompletionRate(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final completionRate = snapshot.data ?? 0;
                return Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: CircularProgressIndicator(
                              value: completionRate / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(AppColors.primary),
                              ),
                            ),
                          ),
                          Text(
                            '$completionRate%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_selectedPeriod 완료율',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리별 통계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.text),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: FutureBuilder<Map<String, int>>(
                future: _getCategoryStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final stats = snapshot.data ?? {};
                  if (stats.isEmpty) {
                    return const Center(
                      child: Text(
                        '데이터가 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  
                  return PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(stats),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '최근 활동',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.text),
              ),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final historyList = ref.watch(historyProvider);
                
                if (historyList.isEmpty) {
                  return const Center(
                    child: Text(
                      '완료된 할일이 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                final recentHistory = historyList.take(5).toList();
                return Column(
                  children: recentHistory.map((history) {
                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(history.category),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        history.title,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        DateFormat('MM/dd HH:mm').format(history.completedAt),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(history.category),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          history.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> stats) {
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.grey,
    ];
    
    final total = stats.values.fold(0, (sum, count) => sum + count);
    int colorIndex = 0;
    
    return stats.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total * 100).round() : 0;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
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

  Future<int> _getCompletionRate() async {
    final databaseService = ref.read(databaseServiceProvider);
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case '오늘':
        return await databaseService.getCompletionRate(now);
      case '이번 주':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        // 주간 평균 계산 (간단히 오늘 기준으로)
        return await databaseService.getCompletionRate(now);
      case '이번 달':
        // 월간 평균 계산 (간단히 오늘 기준으로)
        return await databaseService.getCompletionRate(now);
      default:
        return await databaseService.getCompletionRate(now);
    }
  }

  Future<Map<String, int>> _getCategoryStats() async {
    final databaseService = ref.read(databaseServiceProvider);
    final now = DateTime.now();
    
    DateTime startDate;
    switch (_selectedPeriod) {
      case '오늘':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case '이번 주':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case '이번 달':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }
    
    return await databaseService.getCategoryStats(startDate, now);
  }
} 