import 'package:flutter/material.dart';

/// Thème global de NociBlacK Admin.
///
/// La palette V1 repose sur le noir, le blanc et l’or.
abstract final class AppTheme {
  static const Color gold = Color(0xFFD4AF37);

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.black,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: const OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: gold,
        centerTitle: true,
      ),
    );
  }
}
