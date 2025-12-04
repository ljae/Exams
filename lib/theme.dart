import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF1A237E); // Deep Navy Blue
  static const Color accentColor = Color(0xFFC5A900); // Gold
  static const Color paperColor = Color(0xFFFDFBF7); // Warm Paper
  static const Color textColor = Color(0xFF212121); // Dark Grey for text
  static const Color errorColor = Color(0xFFB00020);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Paperlogy',
      scaffoldBackgroundColor: paperColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        surface: paperColor,
        onSurface: textColor,
        primary: primaryColor,
        secondary: accentColor,
        tertiary: accentColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: paperColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Paperlogy',
          fontWeight: FontWeight.w800,
          fontSize: 24,
          color: primaryColor,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: TextStyle(fontSize: 16, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontFamily: 'Paperlogy', fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIconColor: primaryColor,
      ),
    );
  }
}
