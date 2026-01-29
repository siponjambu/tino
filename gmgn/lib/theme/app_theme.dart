import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0B0E14),
      cardColor: const Color(0xFF131722),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0E14),
      ),
    );
  }
}