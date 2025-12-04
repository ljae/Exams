import 'package:flutter/material.dart';
import 'dart:math' as math;

class TremblingAnswerOption extends StatefulWidget {
  final String text;
  final bool isHesitating;
  final VoidCallback onSelected;
  final Widget child;

  const TremblingAnswerOption({
    super.key,
    required this.text,
    required this.isHesitating,
    required this.onSelected,
    required this.child,
  });

  @override
  State<TremblingAnswerOption> createState() => _TremblingAnswerOptionState();
}

class _TremblingAnswerOptionState extends State<TremblingAnswerOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // Randomize start time to avoid synchronized shaking
    if (widget.isHesitating) {
      _startShaking();
    }
  }

  @override
  void didUpdateWidget(TremblingAnswerOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHesitating != oldWidget.isHesitating) {
      if (widget.isHesitating || _isLongPressing) {
        _startShaking();
      } else {
        _stopShaking();
      }
    }
  }

  void _startShaking() {
    if (!_shakeController.isAnimating) {
      _shakeController.repeat(reverse: true);
    }
  }

  void _stopShaking() {
    if (!_isLongPressing && !widget.isHesitating) {
      _shakeController.stop();
      _shakeController.reset();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelected,
      onLongPressStart: (_) {
        setState(() {
          _isLongPressing = true;
        });
        _startShaking();
      },
      onLongPressEnd: (_) {
        setState(() {
          _isLongPressing = false;
        });
        if (!widget.isHesitating) {
          _stopShaking();
        }
      },
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final offset = _shakeController.value * (_isLongPressing ? 4.0 : 2.0);
          final dx = math.sin(_shakeController.value * math.pi * 2) * offset;
          final dy = math.cos(_shakeController.value * math.pi * 2) * offset;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: widget.child,
          );
        },
      ),
    );
  }
}
