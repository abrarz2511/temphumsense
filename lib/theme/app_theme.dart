import 'package:flutter/material.dart';

class AppTheme {
  // Background colors matching React design
  static const Color background = Color(0xFF0a0a0f);
  static const Color surfaceDark = Color(0xFF0a0a0f);
  static const Color cardBackground = Color(0x0DFFFFFF); // ~5% white opacity
  static const Color cardBorder = Color(0x14FFFFFF); // ~8% white opacity

  // Accent colors
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color amberDark = Color(0xFF92400E);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFFCFFAFE);
  static const Color cyanDark = Color(0xFF164E63);

  // Status colors
  static const Color emerald = Color(0xFF10B981);
  static const Color red = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Text colors
  static const Color textPrimary = Color(0xE6FFFFFF); // 90% white
  static const Color textSecondary = Color(0x80FFFFFF); // 50% white
  static const Color textTertiary = Color(0x40FFFFFF); // 25% white

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: emerald,
      cardColor: cardBackground,
      dividerColor: cardBorder,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
        titleLarge: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textTertiary,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          color: textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}