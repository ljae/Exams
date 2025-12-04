import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetTime;
  final VoidCallback onFinished;
  final Color accentColor;

  const CountdownTimerWidget({
    super.key,
    required this.targetTime,
    required this.onFinished,
    this.accentColor = const Color(0xFFFF4500), // Orange-Red tension color
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _timeLeft;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _startTimer();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    if (now.isAfter(widget.targetTime)) {
      _timeLeft = Duration.zero;
    } else {
      _timeLeft = widget.targetTime.difference(now);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _calculateTimeLeft();
      });

      if (_timeLeft.inSeconds <= 10 && !_pulseController.isAnimating) {
        // Intensify pulse in last 10 seconds
        _pulseController.duration = const Duration(milliseconds: 500);
        _pulseController.repeat(reverse: true);
      }

      if (_timeLeft == Duration.zero) {
        timer.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hours = _twoDigits(_timeLeft.inHours);
    final minutes = _twoDigits(_timeLeft.inMinutes.remainder(60));
    final seconds = _twoDigits(_timeLeft.inSeconds.remainder(60));
    final milliseconds =
        (_timeLeft.inMilliseconds.remainder(1000) / 10).floor().toString().padLeft(2, '0');

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.accentColor.withAlpha((255 * 0.5).toInt()),
            width: 2,
          ),
          color: Colors.black.withAlpha((255 * 0.6).toInt()),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withAlpha((255 * 0.2).toInt()),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDigitGroup(hours, 'HRS'),
            _buildSeparator(),
            _buildDigitGroup(minutes, 'MIN'),
            _buildSeparator(),
            _buildDigitGroup(seconds, 'SEC'),
            _buildSeparator(isSmall: true),
            _buildDigitGroup(milliseconds, 'MS', isSmall: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitGroup(String value, String label, {bool isSmall = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Courier', // Monospace look
            fontSize: isSmall ? 24 : 48,
            fontWeight: FontWeight.bold,
            color: widget.accentColor,
            shadows: [
              Shadow(
                color: widget.accentColor,
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 10,
            color: widget.accentColor.withAlpha((255 * 0.7).toInt()),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator({bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: isSmall ? 24 : 48,
          fontWeight: FontWeight.bold,
          color: widget.accentColor.withAlpha((255 * 0.5).toInt()),
        ),
      ),
    );
  }
}
