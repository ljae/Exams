import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'problem_detail_screen.dart';

class ProblemRevealScreen extends StatefulWidget {
  final Problem problem;

  const ProblemRevealScreen({super.key, required this.problem});

  @override
  State<ProblemRevealScreen> createState() => _ProblemRevealScreenState();
}

class _ProblemRevealScreenState extends State<ProblemRevealScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _markingController;
  
  int _countdownStep = 0; // 0: ID check, 1-5: Countdown bubbles
  String _statusText = "수험생 확인 중...";
  final int _totalCountdown = 5;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 266),
      vsync: this,
    );

    _markingController = AnimationController(
      duration: const Duration(milliseconds: 166),
      vsync: this,
    );

    // Start sequence
    _startSequence();
  }

  void _startSequence() async {
    // Phase 1: Slide in OMR Sheet
    await _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 166));

    // Phase 2: ID Check (Simulated typing/marking)
    // For now, we'll use a mock user.
    setState(() {
      _statusText = "성명: Mock User";
    });
    await Future.delayed(const Duration(milliseconds: 266));
    
    setState(() {
      _statusText = "과목: 수학 영역";
    });
    await Future.delayed(const Duration(milliseconds: 266));

    setState(() {
      _statusText = "시험 준비 완료. 카운트다운 시작";
    });
    await Future.delayed(const Duration(milliseconds: 166));

    // Phase 3: Countdown (Marking bubbles 5 -> 1)
    for (int i = 1; i <= _totalCountdown; i++) {
      setState(() {
        _countdownStep = i;
      });
      _markingController.forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 333));
    }

    // Phase 4: Transition
    _enterExam();
  }

  void _enterExam() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProblemDetailScreen(problem: widget.problem),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 166),
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _markingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0), // Desk color
      body: Center(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: _slideController,
            child: Container(
              width: 340,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // OMR Grid Background
                  CustomPaint(
                    painter: OMRSheetPainter(),
                    size: Size.infinite,
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFFD1DC), width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "OMR",
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Color(0xFFE91E63), // Pinkish Red
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "답안지 (Answer Sheet)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Status / Info
                        Text(
                          "감독관 확인",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: const Color(0xFFEEEEEE),
                          child: Text(
                            _statusText,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Countdown Bubbles
                        Expanded(
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(_totalCountdown, (index) {
                                final bubbleNumber = _totalCountdown - index; // 5, 4, 3, 2, 1
                                final isMarked = _countdownStep > index;
                                final isAnimating = _countdownStep == index + 1;

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "$bubbleNumber",
                                      style: TextStyle(
                                        color: const Color(0xFFE91E63),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 40,
                                      height: 50, // Oval shape
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFE91E63),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: CustomPaint(
                                        painter: BubbleMarkPainter(
                                          isMarked: isMarked,
                                          progress: isAnimating ? _markingController.value : (isMarked ? 1.0 : 0.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            "컴퓨터용 사인펜만 사용하십시오.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OMRSheetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD1DC).withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Draw horizontal guidelines
    for (double y = 100; y < size.height - 50; y += 30) {
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), paint);
    }
    
    // Draw timing marks (black rectangles on the side)
    final markPaint = Paint()..color = Colors.black;
    for (double y = 120; y < size.height - 80; y += 40) {
      canvas.drawRect(Rect.fromLTWH(10, y, 6, 15), markPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BubbleMarkPainter extends CustomPainter {
  final bool isMarked;
  final double progress;

  BubbleMarkPainter({required this.isMarked, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Simulate pen stroke feeling with slight irregularity
    // We draw a growing oval
    final maxW = size.width * 0.7;
    final maxH = size.height * 0.8;
    
    final currentW = maxW * progress;
    final currentH = maxH * progress;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: currentW, height: currentH),
      paint,
    );
  }

  @override
  bool shouldRepaint(BubbleMarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isMarked != isMarked;
  }
}
