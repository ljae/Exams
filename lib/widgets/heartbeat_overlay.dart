import 'package:flutter/material.dart';

class HeartbeatOverlay extends StatefulWidget {
  final bool isActive;

  const HeartbeatOverlay({super.key, required this.isActive});

  @override
  State<HeartbeatOverlay> createState() => _HeartbeatOverlayState();
}

class _HeartbeatOverlayState extends State<HeartbeatOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // Heartbeat speed
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(HeartbeatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Colors.red.withValues(alpha: _opacityAnimation.value),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}
