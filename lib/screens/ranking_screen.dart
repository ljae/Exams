import 'package:flutter/material.dart';
import 'package:world_math/models/models.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets/world_math_app_bar.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Future<List<RankingItem>> _individualRankingsFuture;
  late Future<List<SchoolRankingItem>> _schoolRankingsFuture;
  final FirestoreService _dataService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
    _individualRankingsFuture = _dataService.getRankings();
    _schoolRankingsFuture = _dataService.getSchoolRankings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              'assets/images/ranking.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 8),
            Text(
              '명예의 전당',
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
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_individualRankingsFuture, _schoolRankingsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
            return const Center(child: Text('아직 랭킹이 없습니다.'));
          }

          final individualRankings = snapshot.data![0] as List<RankingItem>;
          final schoolRankings = snapshot.data![1] as List<SchoolRankingItem>;
          // For now, we'll use a mock user ID.
          final currentUserId = 'mock_user_id';

          return Column(
            children: [
              // Top 3 Podium (School Rankings)
              if (schoolRankings.length >= 3)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor.withAlpha((255 * 0.1).toInt()),
                        AppTheme.paperColor,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPodiumItem(schoolRankings[1], 2, 100),
                      _buildPodiumItem(schoolRankings[0], 1, 130),
                      _buildPodiumItem(schoolRankings[2], 3, 80),
                    ],
                  ),
                ),
              if (schoolRankings.length < 3 && schoolRankings.isNotEmpty)
                 Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text("학교 랭킹 데이터를 집계 중입니다.")),
                 ),

              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.grey[100],
                child: const Row(
                  children: [
                    SizedBox(
                        width: 50,
                        child: Text('순위',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(
                        child: Text('이름 / 학교',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))),
                    Text('해결',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),

              // Rankings List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: individualRankings.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final item = individualRankings[index];
                    final isMe = item.userId == currentUserId;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 30)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppTheme.accentColor.withAlpha((255 * 0.15).toInt())
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isMe
                                    ? Border.all(
                                        color: AppTheme.accentColor, width: 2)
                                    : null,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                leading: SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: index < 3
                                        ? Icon(
                                            Icons.emoji_events,
                                            color: index == 0
                                                ? Colors.amber
                                                : (index == 1
                                                    ? Colors.grey[400]
                                                    : Colors.brown[300]),
                                            size: 28,
                                          )
                                        : Text(
                                            '${item.rank}',
                                            style: TextStyle(
                                              fontWeight: isMe
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              fontSize: 18,
                                              color: isMe
                                                  ? AppTheme.accentColor
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      item.nickname,
                                      style: TextStyle(
                                        fontWeight: isMe
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: AppTheme.textColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'ME',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  item.schoolName,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withAlpha((255 * 0.1).toInt()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${item.solvedCount}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
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

  Widget _buildPodiumItem(SchoolRankingItem item, int position, double height) {
    final colors = [
      Colors.amber,
      Colors.grey[400]!,
      Colors.brown[300]!
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (position * 100)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[position - 1],
                  boxShadow: [
                    BoxShadow(
                      color: colors[position - 1].withAlpha((255 * 0.4).toInt()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.schoolName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${item.totalSolvedCount}문제',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: Duration(milliseconds: 500 + (position * 100)),
              curve: Curves.easeOut,
              width: 80,
              height: height * value,
              decoration: BoxDecoration(
                color: colors[position - 1].withAlpha((255 * 0.3).toInt()),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                border: Border.all(color: colors[position - 1], width: 2),
              ),
              child: Center(
                child: Icon(
                  Icons.school, // Changed icon to school
                  color: colors[position - 1],
                  size: 30,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
