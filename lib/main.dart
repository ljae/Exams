import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:world_math/services/firestore_service.dart'; // Keep this import
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Seed the database with problems and dummy users (최초 1회만 실행)
  // ✅ 데이터가 Firebase에 업로드 완료되어 주석 처리됨
  // try {
  //   await FirestoreService().seedDatabase();
  //   await FirestoreService().seedDummyUsers();
  //   print('Database seeded successfully!');
  // } catch (e) {
  //   print('Error seeding database: $e');
  // }

  await initializeDateFormatting('ko_KR', null);
  runApp(const WorldMathApp());
}

class WorldMathApp extends StatelessWidget {
  const WorldMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '대치동 김부장 아들의 세상수학',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
