import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _symbolController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  
  // Floating symbols
  final List<FloatingSymbol> _symbols = [];
  final List<String> _mathSymbols = ['∑', '∫', 'π', '%', '\$', '√', '∞', '≠'];
  final int _symbolCount = 15;

  String _displayedText = "";
  final String _fullText = "대치동 김부장 아들의\n세상수학";
  
  @override
  void initState() {
    super.initState();

    // Initialize floating symbols
    final random = math.Random();
    for (int i = 0; i < _symbolCount; i++) {
      _symbols.add(FloatingSymbol(
        symbol: _mathSymbols[random.nextInt(_mathSymbols.length)],
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 20 + random.nextDouble() * 40,
        speed: 0.2 + random.nextDouble() * 0.5,
        opacity: 0.1 + random.nextDouble() * 0.2,
        angle: random.nextDouble() * 2 * math.pi,
      ));
    }

    // Logo animation (Spring effect)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Symbol animation (Continuous)
    _symbolController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Start sequence
    _startSequence();
  }

  void _startSequence() async {
    // 1. Logo appears with spring effect
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // 2. Typewriter effect for text
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    _typeWriterEffect();

    // 3. Navigate to login
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _typeWriterEffect() async {
    for (int i = 0; i <= _fullText.length; i++) {
      if (!mounted) return;
      setState(() {
        _displayedText = _fullText.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E), // Dark Navy
              Color(0xFF16213E), // Slightly lighter Navy
              Color(0xFF0F3460), // Deep Blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating Symbols Background
            AnimatedBuilder(
              animation: _symbolController,
              builder: (context, child) {
                return Stack(
                  children: _symbols.map((symbol) {
                    // Update position based on time
                    double currentY = (symbol.y - _symbolController.value * symbol.speed) % 1.0;
                    if (currentY < 0) currentY += 1.0;

                    return Positioned(
                      left: symbol.x * MediaQuery.of(context).size.width,
                      top: currentY * MediaQuery.of(context).size.height,
                      child: Transform.rotate(
                        angle: symbol.angle + _symbolController.value * 2 * math.pi * 0.1,
                        child: Text(
                          symbol.symbol,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: symbol.opacity),
                            fontSize: symbol.size,
                            fontFamily: 'Courier', // Monospace for math feel
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Container(
                        width: 400,
                        height: 400,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Typewriter Text
                  SizedBox(
                    height: 150, // Increased height to prevent overflow
                    child: Column(
                      children: [
                        Text(
                          _displayedText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Text(
                            '현실감각 체험수학',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 4.0,
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
          ],
        ),
      ),
    );
  }
}

class FloatingSymbol {
  final String symbol;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double angle;

  FloatingSymbol({
    required this.symbol,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
  });
}
