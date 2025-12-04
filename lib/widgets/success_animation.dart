import 'package:flutter/material.dart';
import 'dart:math' as math;

class SuccessAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const SuccessAnimation({super.key, required this.onComplete});

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _circleController;
  late AnimationController _confettiController;
  late Animation<double> _checkAnimation;
  late Animation<double> _circleAnimation;

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _circleController.forward();
    await _checkController.forward();
    _confettiController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _circleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti background
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(_confettiController.value),
              child: Container(),
            );
          },
        ),
        // Success check icon
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_circleController, _checkController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _circleAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: CheckmarkPainter(_checkAnimation.value),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw checkmark
    path.moveTo(centerX - 20, centerY);
    path.lineTo(centerX - 5, centerY + 15);
    path.lineTo(centerX + 20, centerY - 15);

    final pathMetric = path.computeMetrics().first;
    final extractPath = pathMetric.extractPath(
      0.0,
      pathMetric.length * progress,
    );

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.progress)
      : particles = List.generate(
          30,
          (index) => ConfettiParticle(
            math.Random(index).nextDouble() * 400 - 200,
            math.Random(index + 100).nextDouble() * 400 - 200,
            Color((math.Random(index).nextDouble() * 0xFFFFFF).toInt())
                .withValues(alpha: 1.0),
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (var particle in particles) {
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity);

      final x = centerX + particle.x * progress;
      final y = centerY + particle.y * progress - (progress * 100);

      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ConfettiParticle {
  final double x;
  final double y;
  final Color color;

  ConfettiParticle(this.x, this.y, this.color);
}
