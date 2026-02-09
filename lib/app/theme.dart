import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF6D5DF6);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _primary),
      scaffoldBackgroundColor: const Color(0xFFF8F7FB),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
