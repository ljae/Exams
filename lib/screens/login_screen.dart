import 'package:flutter/material.dart';
import 'package:world_math/models/models.dart';
import '../theme.dart';
import '../services/firestore_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _schoolController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  final FirestoreService _dataService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nicknameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // For now, we'll use a mock user ID.
      final userId = 'mock_user_id';
      final user = User(
        id: userId,
        nickname: _nicknameController.text,
        schoolName: _schoolController.text,
      );
      await _dataService.updateUser(user);

      // Simulate loading
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.paperColor,
              AppTheme.paperColor,
              AppTheme.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 270,
                              height: 270,
                              padding: const EdgeInsets.all(20.0),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        '대치동 김부장 아들의\n세상수학',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              height: 1.3,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '현실감각 체험수학',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 48),

                      // Inputs
                      TextFormField(
                        controller: _nicknameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: '닉네임',
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: '사용할 닉네임을 입력하세요',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '닉네임을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // School Autocomplete
                      Autocomplete<School>(
                        displayStringForOption: (School option) => option.school_name,
                        optionsBuilder: (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text == '') {
                            return const Iterable<School>.empty();
                          }
                          try {
                            return await _dataService.searchSchools(textEditingValue.text);
                          } catch (e) {
                            print('Error searching schools: $e');
                            return const Iterable<School>.empty();
                          }
                        },
                        onSelected: (School selection) {
                          _schoolController.text = selection.school_name;
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                          // Sync initial value if needed
                          if (_schoolController.text.isNotEmpty && fieldTextEditingController.text.isEmpty) {
                            fieldTextEditingController.text = _schoolController.text;
                          }
                          
                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: const InputDecoration(
                              labelText: '학교',
                              prefixIcon: Icon(Icons.school_outlined),
                              hintText: '학교를 검색하세요',
                            ),
                            onChanged: (value) {
                              // Sync manual input to _schoolController
                              _schoolController.text = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '학교를 입력해주세요';
                              }
                              return null;
                            },
                          );
                        },
                        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<School> onSelected, Iterable<School> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              color: Colors.white, // Ensure background color
                              child: SizedBox(
                                width: 300,
                                height: 200, // Limit height to prevent layout issues
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final School option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option.school_name),
                                      subtitle: Text(option.location),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: _isLoading ? 0 : 4,
                            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login, size: 20),
                                    SizedBox(width: 8),
                                    Text('입장하기', style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
