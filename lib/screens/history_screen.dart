import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets/animated_card.dart';
import 'package:intl/intl.dart';
import '../widgets/world_math_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Attempt>> _historyFuture;
  final FirestoreService _dataService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Get the current user's ID and fetch their history.
    // For now, we'll use a mock user ID.
    final userId = 'mock_user_id';
    _historyFuture = _dataService.getHistory(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WorldMathAppBar(
        title: '',
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/history.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 8),
            Text(
              '나의 학습 기록',
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Attempt>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(Icons.history_toggle_off,
                            size: 80, color: Colors.grey[400]),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '아직 푼 문제가 없습니다.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '첫 문제를 풀어보세요!',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final history = snapshot.data!;
          final correctCount = history.where((r) => r.isCorrect).length;
          final totalCount = history.length;

          return Column(
            children: [
              // Statistics Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withAlpha((255 * 0.8).toInt()),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha((255 * 0.3).toInt()),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.assignment_turned_in,
                      label: '푼 문제',
                      value: '$totalCount',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withAlpha((255 * 0.3).toInt()),
                    ),
                    _buildStatItem(
                      icon: Icons.check_circle,
                      label: '정답',
                      value: '$correctCount',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withAlpha((255 * 0.3).toInt()),
                    ),
                    _buildStatItem(
                      icon: Icons.trending_up,
                      label: '정답률',
                      value: totalCount > 0
                          ? '${((correctCount / totalCount) * 100).toStringAsFixed(0)}%'
                          : '0%',
                    ),
                  ],
                ),
              ),

              // History List
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    // Show latest first
                    final record = history[history.length - 1 - index];
                    return FutureBuilder<Problem?>(
                      future: _dataService.getProblemById(record.problemId),
                      builder: (context, problemSnapshot) {
                        if (problemSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            !problemSnapshot.hasData) {
                          return const SizedBox.shrink(); // Or a placeholder
                        }
                        final problem = problemSnapshot.data;
                        if (problem == null) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedCard(
                            index: index,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: record.isCorrect
                                      ? Colors.green.withAlpha((255 * 0.1).toInt())
                                      : AppTheme.errorColor.withAlpha((255 * 0.1).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  record.isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: record.isCorrect
                                      ? Colors.green
                                      : AppTheme.errorColor,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                problem.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '풀이 일시: ${DateFormat('yyyy.MM.dd HH:mm').format(record.solvedAt)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (record.timeTakenSeconds > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          '소요 시간: ${record.timeTakenSeconds ~/ 60}분 ${record.timeTakenSeconds % 60}초',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: record.isCorrect
                                      ? Colors.green
                                      : AppTheme.errorColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  record.isCorrect ? '정답' : '오답',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withAlpha((255 * 0.9).toInt()),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
