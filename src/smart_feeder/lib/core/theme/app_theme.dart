import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF080808);
  static const Color surface = Color(0xFF121212);
  static const Color cyberGreen = Color(0xFF00FF94);
  static const Color deepCharcoal = Color(0xFF080808);
  static const Color glassBorder = Color(0xFF1E1E1E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyberGreen,
        brightness: Brightness.dark,
        primary: cyberGreen,
        surface: surface,
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
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyberGreen, width: 1),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
