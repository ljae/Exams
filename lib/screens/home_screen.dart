import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/animated_card.dart';
import '../widgets/custom_snackbar.dart';
import 'problem_detail_screen.dart';
import 'problem_reveal_screen.dart';
import '../widgets/world_math_app_bar.dart';
import '../widgets/mini_calendar_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _dataService = FirestoreService();
  
  DateTime _currentWeekStart = DateTime.now();
  List<Problem> _problems = [];
  Set<String> _solvedIds = {};
  Set<String> _revealedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize to the Monday of the current week
    final now = DateTime.now();
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    _currentWeekStart = DateTime(_currentWeekStart.year, _currentWeekStart.month, _currentWeekStart.day);
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final problems = await _dataService.getProblemsByWeek(_currentWeekStart);
      final solvedIds = <String>{};
      final revealedIds = <String>{};

      // For now, we'll use a mock user ID.
      final userId = 'mock_user_id';

      for (var p in problems) {
        if (await _dataService.hasSolved(userId, p.id)) {
          solvedIds.add(p.id);
        }
        if (await _dataService.hasRevealed(userId, p.id)) {
          revealedIds.add(p.id);
        }
      }

      if (mounted) {
        setState(() {
          _problems = problems;
          _solvedIds = solvedIds;
          _revealedIds = revealedIds;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print(stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changeWeek(int offset) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: offset * 7));
    });
    _loadData();
  }

  void _openProblem(Problem problem) async {
    // For now, we'll use a mock user ID.
    final userId = 'mock_user_id';
    
    bool isRevealed = _revealedIds.contains(problem.id);
    
    if (isRevealed) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProblemDetailScreen(problem: problem),
        ),
      ).then((_) => _loadData());
    } else {
      await _dataService.markRevealed(userId, problem.id);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProblemRevealScreen(problem: problem),
          ),
        ).then((_) => _loadData());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Scaffold(
      appBar: WorldMathAppBar(
        title: '${_currentWeekStart.year}년 ${_getWeekNumber(_currentWeekStart)}주차',
        titleWidget: LayoutBuilder(
          builder: (context, constraints) {
            // Check available width for the title area
            // We need enough space for Text (~150px) + Controls (~130px) + Spacing
            final showText = constraints.maxWidth > 300;

            return Row(
              mainAxisAlignment: showText ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                if (showText) ...[
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0), // Adjust alignment
                            child: Text(
                              '${_currentWeekStart.year}',
                              style: TextStyle(
                                fontFamily: 'Paperlogy',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' ${_getWeekNumber(_currentWeekStart)}주차',
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
                  const Spacer(),
                ],
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha((255 * 0.08).toInt()),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.withAlpha((255 * 0.1).toInt())),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavArrow(Icons.chevron_left_rounded, () => _changeWeek(-1)),
                        const SizedBox(width: 2),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 72),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: MiniCalendarIcon(date: _currentWeekStart, size: 72),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        _buildNavArrow(Icons.chevron_right_rounded, () => _changeWeek(1)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _problems.isEmpty
              ? const Center(child: Text("등록된 문제가 없습니다."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _problems.length,
                  itemBuilder: (context, index) {
                    final problem = _problems[index];
                    // Lock logic: Lock if problem date is in the future relative to REAL time
                    // But allow viewing past weeks.
                    // If we are viewing a past week, all should be unlocked (unless future relative to now).
                    // If we are viewing future week, all locked.
                    
                    // Simple check: is problem.date > now?
                    // Note: problem.date might have time 00:00.
                    // If today is Mon, Mon problem (00:00) is <= now.
                    final isLocked = problem.date.isAfter(now) && !isSameDay(problem.date, now);
                    final isSolved = _solvedIds.contains(problem.id);
                    
                    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
                    final koreanDay = weekDays[problem.date.weekday - 1];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnimatedCard(
                        index: index,
                        color: isLocked ? Colors.grey[200] : Colors.white,
                        onTap: isLocked ? () {
                          CustomSnackbar.show(
                            context,
                            message: '아직 공개되지 않은 문제입니다.',
                            type: SnackbarType.warning,
                          );
                        } : () => _openProblem(problem),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Hero(
                            tag: 'problem_${problem.id}',
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLocked ? Colors.grey : (isSolved ? AppTheme.primaryColor : Colors.white),
                                border: Border.all(
                                  color: isLocked ? Colors.grey : AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isLocked
                                  ? const Icon(Icons.lock, size: 20, color: Colors.white)
                                  : (isSolved
                                      ? const Icon(Icons.check, size: 20, color: Colors.white)
                                      : Text(
                                          koreanDay,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        )),
                              ),
                            ),
                          ),
                          title: Text(
                            problem.title,
                            style: TextStyle(
                              color: isLocked ? Colors.grey : AppTheme.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              ), 
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('yyyy.MM.dd').format(problem.date),
                              style: TextStyle(
                                color: isLocked ? Colors.grey : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          trailing: isLocked
                            ? null
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppTheme.primaryColor.withAlpha((255 * 0.7).toInt()),
                              ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildNavArrow(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 24,
            color: AppTheme.primaryColor.withAlpha((255 * 0.8).toInt()),
          ),
        ),
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
