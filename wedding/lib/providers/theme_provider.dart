// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Custom dark theme with professional colors
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF6C63FF), // A professional purple
      primaryColorDark: const Color(0xFF524BDB), // Darker purple
      primaryColorLight: const Color(0xFFA29BFE), // Lighter purple
      scaffoldBackgroundColor: const Color(
        0xFF121212,
      ), // Dark gray instead of pure black
      cardColor: const Color(0xFF1E1E1E), // Slightly lighter than scaffold
      // backgroundColor: const Color(0xFF1E1E1E), // Removed invalid parameter
      dialogBackgroundColor: const Color(0xFF1E1E1E),
      indicatorColor: const Color(0xFF6C63FF),
      hintColor: const Color(0xFF8A8A8A),
      dividerColor: const Color(0xFF343434), // Subtle divider
      disabledColor: const Color(0xFF5A5A5A),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF6C63FF),
        selectionColor: Color(0x556C63FF), // Transparent version of primary
        selectionHandleColor: Color(0xFF6C63FF),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF03DAC6), // Teal accent
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        error: Color(0xFFCF6679),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Color(0xFFE0E0E0)), // Light gray
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFB0B0B0)), // Medium gray
        bodySmall: TextStyle(color: Color(0xFF8A8A8A)), // Dark gray
        labelLarge: TextStyle(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
        labelStyle: const TextStyle(color: Color(0xFFE0E0E0)),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
    );
  }

  // Custom light theme for consistency
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: const Color(0xFF6C63FF),
      primaryColorDark: const Color(0xFF524BDB),
      primaryColorLight: const Color(0xFFA29BFE),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF6C63FF),
        selectionColor: Color(0x556C63FF),
        selectionHandleColor: Color(0xFF6C63FF),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF03DAC6),
      ),
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
    );
  }
}
