import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'history_screen.dart';
import '../theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late List<AnimationController> _iconControllers;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RankingScreen(),
    const HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _iconControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _iconControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _iconControllers[_selectedIndex].reverse();
      _selectedIndex = index;
      _iconControllers[_selectedIndex].forward();
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _iconControllers[_selectedIndex].reverse();
            _selectedIndex = index;
            _iconControllers[_selectedIndex].forward();
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.calendar_today_outlined, Icons.calendar_today, 0),
              label: '이번주 문제',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.leaderboard_outlined, Icons.leaderboard, 1),
              label: '랭킹',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.history_outlined, Icons.history, 2),
              label: '내 기록',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData outlinedIcon, IconData filledIcon, int index) {
    return AnimatedBuilder(
      animation: _iconControllers[index],
      builder: (context, child) {
        final isSelected = _selectedIndex == index;
        return Transform.scale(
          scale: 1.0 + (_iconControllers[index].value * 0.2),
          child: Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey,
          ),
        );
      },
    );
  }
}
