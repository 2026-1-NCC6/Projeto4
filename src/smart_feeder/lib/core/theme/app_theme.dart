import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundDark = Color(0xFF080808);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cyberGreen = Color(0xFF00FF94);
  static const Color glassBorderDark = Color(0xFF1E1E1E);

  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color glassBorderLight = Color(0xFFE0E0E0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyberGreen,
        brightness: Brightness.dark,
        primary: cyberGreen,
        surface: surfaceDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: cyberGreen,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 32),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 20),
        labelMedium: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, letterSpacing: 1.5, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyberGreen,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyberGreen, width: 1),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyberGreen,
        brightness: Brightness.light,
        primary: cyberGreen,
        surface: surfaceLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 32),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 20),
        labelMedium: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, letterSpacing: 1.5, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyberGreen,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyberGreen, width: 1),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
      ),
    );
  }
}
