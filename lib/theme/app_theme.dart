import 'package:flutter/material.dart';

/// Brand palette shared with the OpenTides app — deep ocean navy with cyan
/// accents — so the two apps read as one family. The brand is intentionally
/// dark-only; [light] returns the same theme so call sites can pass it as the
/// `theme:` fallback while the app is pinned to dark mode.
class AppTheme {
  static const navy = Color(0xFF0A1628);
  static const navyLight = Color(0xFF0D2137);
  static const cyan = Color(0xFF00BCD4);
  static const cyanLight = Color(0xFF4DD0E1);
  static const cardBg = Color(0xFF0F1F35);

  /// Brand is dark-only; mirror [dark] so light system mode still reads on-brand.
  static ThemeData light() => dark();

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: cyanLight,
        surface: navyLight,
        onPrimary: navy,
        onSecondary: navy,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: navy,
      cardColor: cardBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: navyLight,
        foregroundColor: cyan,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: cardBg,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: cyan, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        labelSmall: TextStyle(color: Colors.white54),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cyan, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cyan.withValues(alpha: 0.4), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cyan, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
