import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../widgets/success_animation.dart';
import 'dart:io';
import 'dart:async';



class ProblemDetailScreen extends StatefulWidget {
  final Problem problem;

  const ProblemDetailScreen({super.key, required this.problem});

  @override
  State<ProblemDetailScreen> createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends State<ProblemDetailScreen> with SingleTickerProviderStateMixin {
  final _answerController = TextEditingController();
  bool _isSubmitted = false;
  bool _isCorrect = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Timer state
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isTimerRunning = false;

  String _mathTopic = '';
  String _economicTheme = '';
  String _cleanContent = '';

  final FirestoreService _dataService = FirestoreService();

  @override
  void initState() {
    super.initState();

    // Extract category info and clean content
    _extractCategoryInfo();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Check if already solved
    _checkIfSolved();
    
    // Start timer
    _startTimer();
  }
  
  void _startTimer() {
    if (_isTimerRunning) return;
    
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }
  
  void _stopTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
  }

  Future<void> _checkIfSolved() async {
    // For now, we'll use a mock user ID.
    final userId = 'mock_user_id';
    final hasSolved = await _dataService.hasSolved(userId, widget.problem.id);
    if (mounted && hasSolved) {
      setState(() {
        _isSubmitted = true;
        _isCorrect = true;
        _isTimerRunning = false; // Don't run timer if already solved
      });
    }
  }

  void _extractCategoryInfo() {
    final lines = widget.problem.content.split('\n');
    final contentLines = <String>[];

    for (var line in lines) {
      if (line.startsWith('수학적 주제:')) {
        _mathTopic = line.replaceFirst('수학적 주제:', '').trim();
      } else if (line.startsWith('경제적 테마:')) {
        _economicTheme = line.replaceFirst('경제적 테마:', '').trim();
      } else {
        contentLines.add(line);
      }
    }

    _cleanContent = contentLines.join('\n');
  }

  @override
  void dispose() {
    _stopTimer();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_answerController.text.isEmpty) return;

    _stopTimer(); // Stop timer on submit

    // For now, we'll use a mock user ID.
    final userId = 'mock_user_id';
    final isCorrect = _answerController.text == widget.problem.correctAnswer;
    await _dataService.recordAttempt(
      userId,
      widget.problem.id, 
      isCorrect,
      timeTakenSeconds: _elapsedSeconds,
    );

    setState(() {
      _isSubmitted = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _showResultDialog('정답입니다!', true);
    } else {
      _showResultDialog('오답입니다. 다시 풀어보세요.', false);
      setState(() {
        _isSubmitted = false; // Allow retry
        _startTimer(); // Resume timer
      });
    }
  }

  void _showResultDialog(String message, bool success) {
    if (success) {
      // Show full-screen success animation
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withAlpha((255 * 0.7).toInt()),
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: SuccessAnimation(
            onComplete: () {
              Navigator.pop(context);
              _showSuccessMessage();
            },
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text('아쉬워요'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text('다시 도전'),
            ),
          ],
        ),
      );
    }
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            SizedBox(width: 8),
            Text('축하합니다!'),
          ],
        ),
        content: const Text('정답입니다! 해설을 확인해보세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchNewsUrl() async {
    final urlString = widget.problem.newsUrl?.trim();
    if (urlString != null && urlString.isNotEmpty) {
      final Uri? url = Uri.tryParse(urlString);
      if (url != null && url.hasScheme) {
        if (!await launchUrl(url)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('뉴스 링크를 열 수 없습니다.')),
            );
          }
        }
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('유효하지 않은 링크입니다.')),
          );
        }
      }
    }
  }

  String _getDayOfWeek() {
    final weekday = widget.problem.date.weekday;
    const days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return days[weekday - 1];
  }

  Widget _buildProblemContent() {
    final lines = _cleanContent.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip empty lines at certain positions to reduce excessive spacing
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Check for [[IMAGE]] marker
      if (line.trim() == '[[IMAGE]]') {
        if (widget.problem.imageUrl != null) {
          widgets.add(const SizedBox(height: 16));
          widgets.add(Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400), // Increased max width
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: InteractiveViewer( // Added zoom capability
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: _buildImageWidget(widget.problem.imageUrl!),
              ),
            ),
          ));
          widgets.add(const SizedBox(height: 16));
        }
        continue;
      }

      // Check if line is a multiple choice option
      if (RegExp(r'^[①②③④⑤]').hasMatch(line)) {
        final optionNumber = line.substring(0, 1); // Extract ①
        // Map circle number to actual number string (1-5)
        final answerMap = {'①': '1', '②': '2', '③': '3', '④': '4', '⑤': '5'};
        final answerValue = answerMap[optionNumber] ?? '';

        widgets.add(
          GestureDetector(
            onTap: () {
              setState(() {
                _answerController.text = answerValue;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: _answerController.text == answerValue
                    ? Colors.blue.withAlpha((255 * 0.1).toInt())
                    : Colors.grey.withAlpha((255 * 0.05).toInt()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _answerController.text == answerValue
                      ? Colors.blue
                      : Colors.grey.withAlpha((255 * 0.2).toInt()),
                  width: _answerController.text == answerValue ? 2 : 1,
                ),
              ),
              child: _buildFormattedText(line, fontSize: 16),
            ),
          ),
        );
      }
      // Check if line is a section header (starts with number and period)
      else if (RegExp(r'^\d+\.').hasMatch(line)) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildFormattedText(line, fontSize: 20, isBold: true));
        widgets.add(const SizedBox(height: 12));
      }
      // Check if line is Q. (question marker)
      else if (line.startsWith('Q.')) {
        widgets.add(const SizedBox(height: 12));
        widgets.add(_buildFormattedText(line, fontSize: 18, isBold: true));
        widgets.add(const SizedBox(height: 12));
      }
      // Regular paragraph
      else {
        widgets.add(_buildFormattedText(line));
        widgets.add(const SizedBox(height: 8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildFormattedText(String text, {double fontSize = 17, bool isBold = false}) {
    // Check for display math ($$...$$) first
    if (text.contains(r'$$')) {
      return _buildMathText(text, fontSize, isBold, isDisplay: true);
    }

    // Check for inline math ($...$)
    if (text.contains(r'$')) {
      return _buildMathText(text, fontSize, isBold, isDisplay: false);
    }

    // No math, just handle bold text
    return _buildPlainText(text, fontSize, isBold);
  }

  Widget _buildPlainText(String text, double fontSize, bool isBold) {
    // Parse bold text marked with **
    final parts = <TextSpan>[];
    final regex = RegExp(r'\*\*([^*]+)\*\*');
    var lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the bold part
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: fontSize,
            height: 1.8,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.3,
          ),
        ));
      }

      // Add bold part
      parts.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontFamily: 'Paperlogy',
          fontSize: fontSize,
          height: 1.8,
          color: Colors.black,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          fontFamily: 'Paperlogy',
          fontSize: fontSize,
          height: 1.8,
          color: Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          letterSpacing: 0.3,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: parts),
    );
  }

  Widget _buildMathText(String text, double fontSize, bool isBold, {required bool isDisplay}) {
    final children = <InlineSpan>[];

    // For display math $$...$$
    if (isDisplay) {
      final displayMathRegex = RegExp(r'\$\$([^\$]+)\$\$');
      var lastEnd = 0;

      for (final match in displayMathRegex.allMatches(text)) {
        // Add text before math
        if (match.start > lastEnd) {
          final beforeText = text.substring(lastEnd, match.start);
          children.add(WidgetSpan(
            child: _buildPlainText(beforeText, fontSize, isBold),
          ));
        }

        // Add display math
        children.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Math.tex(
                match.group(1) ?? '',
                textStyle: TextStyle(
                  fontSize: fontSize + 2,
                  fontFamily: 'Paperlogy',
                  color: Colors.black,
                ),
                mathStyle: MathStyle.display,
                onErrorFallback: (error) => Text(
                  match.group(1)!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ));

        lastEnd = match.end;
      }

      // Add remaining text
      if (lastEnd < text.length) {
        children.add(WidgetSpan(
          child: _buildPlainText(text.substring(lastEnd), fontSize, isBold),
        ));
      }
    }
    // For inline math $...$
    else {
      final inlineMathRegex = RegExp(r'\$([^\$]+)\$');
      var lastEnd = 0;

      for (final match in inlineMathRegex.allMatches(text)) {
        // Add text before math
        if (match.start > lastEnd) {
          final beforeText = text.substring(lastEnd, match.start);
          final parsedBefore = _parseTextWithBold(beforeText, fontSize, isBold);
          children.addAll(parsedBefore);
        }

        // Add inline math
        children.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            match.group(1) ?? '',
            textStyle: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Paperlogy',
              color: Colors.black,
            ),
            mathStyle: MathStyle.text,
            onErrorFallback: (error) => Text(
              match.group(1)!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ));

        lastEnd = match.end;
      }

      // Add remaining text
      if (lastEnd < text.length) {
        final remainingText = text.substring(lastEnd);
        final parsedRemaining = _parseTextWithBold(remainingText, fontSize, isBold);
        children.addAll(parsedRemaining);
      }
    }

    return RichText(
      text: TextSpan(children: children),
    );
  }

  List<InlineSpan> _parseTextWithBold(String text, double fontSize, bool isBold) {
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\*\*([^*]+)\*\*');
    var lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before bold
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: fontSize,
            height: 1.8,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.3,
          ),
        ));
      }

      // Add bold text
      parts.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontFamily: 'Paperlogy',
          fontSize: fontSize,
          height: 1.8,
          color: Colors.black,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          fontFamily: 'Paperlogy',
          fontSize: fontSize,
          height: 1.8,
          color: Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          letterSpacing: 0.3,
        ),
      ));
    }

    return parts;
  }

  Widget _buildExplanationContent() {
    final lines = widget.problem.explanation.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip empty lines
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Check if line is a heading (starts with #)
      if (line.startsWith('###')) {
        final headingText = line.replaceFirst('###', '').trim();
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildFormattedText(headingText, fontSize: 20, isBold: true));
        widgets.add(const SizedBox(height: 12));
      } else if (line.startsWith('##')) {
        final headingText = line.replaceFirst('##', '').trim();
        widgets.add(const SizedBox(height: 20));
        widgets.add(_buildFormattedText(headingText, fontSize: 22, isBold: true));
        widgets.add(const SizedBox(height: 16));
      }
      // Check if line starts with ** (bold section titles)
      else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(const SizedBox(height: 12));
        widgets.add(_buildFormattedText(line, fontSize: 17, isBold: true));
        widgets.add(const SizedBox(height: 8));
      }
      // Check if line is a blockquote (starts with >)
      else if (line.startsWith('>')) {
        final quoteText = line.replaceFirst('>', '').trim();
        if (quoteText.isEmpty) {
          // Skip empty blockquote lines
          continue;
        }
        widgets.add(Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha((255 * 0.05).toInt()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withAlpha((255 * 0.3).toInt()),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withAlpha((255 * 0.1).toInt()),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildFormattedText(quoteText, fontSize: 15),
        ));
      }
      // Check if line is a list item (starts with *)
      else if (line.trim().startsWith('*') || line.trim().startsWith('-')) {
        final listText = line.trim().replaceFirst(RegExp(r'^[\*\-]\s*'), '');
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 17, height: 1.8)),
              Expanded(child: _buildFormattedText(listText, fontSize: 16)),
            ],
          ),
        ));
      }
      // Horizontal rule (---)
      else if (line.trim() == '---') {
        widgets.add(const SizedBox(height: 20));
        widgets.add(Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.grey.withAlpha((255 * 0.5).toInt()),
                Colors.transparent,
              ],
            ),
          ),
        ));
        widgets.add(const SizedBox(height: 20));
      }
      // Regular paragraph
      else {
        widgets.add(_buildFormattedText(line, fontSize: 16));
        widgets.add(const SizedBox(height: 8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildCategoryBadge(String label, String content, Color color) {
    // Create a darker version of the color for text
    final HSLColor hslColor = HSLColor.fromColor(color);
    final Color darkColor = hslColor.withLightness(0.3).toColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).toInt()),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'Paperlogy',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: darkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Paper color
      appBar: AppBar(
        title: const Text(
          '2025학년도 대학수학능력시험 대비',
          style: TextStyle(
            fontFamily: 'Paperlogy',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFDFBF7),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
            height: 2.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 120,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timer Display
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((255 * 0.2).toInt()),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Day Indicator with Animation
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade700,
                                      Colors.blue.shade500,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withAlpha((255 * 0.4).toInt()),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getDayOfWeek(),
                                      style: const TextStyle(
                                        fontFamily: 'Paperlogy',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Badges
                      if (_mathTopic.isNotEmpty || _economicTheme.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_mathTopic.isNotEmpty)
                              _buildCategoryBadge('수학', _mathTopic, Colors.purple),
                            if (_economicTheme.isNotEmpty)
                              _buildCategoryBadge('경제', _economicTheme, Colors.orange),
                          ],
                        ),
                      if (_mathTopic.isNotEmpty || _economicTheme.isNotEmpty)
                        const SizedBox(height: 24),

                      // Divider
                      Container(
                        height: 2,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 24),

                      // Problem Content with custom rendering
                      _buildProblemContent(),
                      const SizedBox(height: 32),
                      
                      if (widget.problem.imageUrl != null && !_cleanContent.contains('[[IMAGE]]')) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: File(widget.problem.imageUrl!).existsSync()
                              ? Image.file(
                                  File(widget.problem.imageUrl!),
                                  fit: BoxFit.contain,
                                )
                              : widget.problem.imageUrl!.startsWith('assets/')
                                  ? Image.asset(
                                      widget.problem.imageUrl!,
                                      fit: BoxFit.contain,
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(20),
                                      color: Colors.grey[200],
                                      child: const Text('이미지를 불러올 수 없습니다'),
                                    ),
                        ),
                      ],

                      const SizedBox(height: 40),
                  
                      // News Section
                      if (widget.problem.newsTitle != null) ...[
                        Container(
                          height: 2,
                          color: Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _launchNewsUrl,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha((255 * 0.1).toInt()),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.newspaper, color: Colors.blue.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '관련 경제 뉴스',
                                      style: TextStyle(
                                        fontFamily: 'Paperlogy',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.problem.newsTitle!,
                                  style: const TextStyle(
                                    fontFamily: 'Paperlogy',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (_isSubmitted && _isCorrect) ...[
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha((255 * 0.05).toInt()),
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    '정답 및 해설',
                                    style: TextStyle(
                                      fontFamily: 'Paperlogy',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildExplanationContent(),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.05).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isSubmitted || !_isCorrect)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _answerController,
                              decoration: InputDecoration(
                                hintText: '정답을 입력하세요',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                prefixIcon: const Icon(Icons.create),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              autofocus: false,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Material(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: _submit,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: const Row(
                                  children: [
                                    Icon(Icons.send, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      '제출',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_isSubmitted && _isCorrect)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text('목록으로'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    // On web, File operations are not supported
    if (kIsWeb) {
      // For web, check if it's an asset path
      if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.contain,
        );
      } else {
        // For web, treat other paths as network images or show error
        return Container(
          padding: const EdgeInsets.all(20),
          color: Colors.grey[200],
          child: const Text('이미지를 불러올 수 없습니다'),
        );
      }
    }

    // For mobile/desktop platforms
    if (File(imageUrl).existsSync()) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[200],
        child: const Text('이미지를 불러올 수 없습니다'),
      );
    }
  }
}

// Custom builder to render LaTeX math
class MathMarkdownBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final math = element.textContent;
    if (math.isEmpty) return const SizedBox.shrink();

    final isDisplay = element.attributes['type'] == 'display';

    if (isDisplay) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Math.tex(
            math,
            textStyle: const TextStyle(
              fontSize: 18,
              fontFamily: 'Paperlogy',
              color: Colors.black,
            ),
            mathStyle: MathStyle.display,
            onErrorFallback: (error) => Text(
              math,
              style: const TextStyle(color: Colors.blue), // Blue for debugging
            ),
          ),
        ),
      );
    }

    return Math.tex(
      math,
      textStyle: const TextStyle(
        fontSize: 16,
        fontFamily: 'Paperlogy',
        color: Colors.black,
      ),
      mathStyle: MathStyle.text,
      onErrorFallback: (error) => Text(
        math,
        style: const TextStyle(color: Colors.blue), // Blue for debugging
      ),
    );
  }
}