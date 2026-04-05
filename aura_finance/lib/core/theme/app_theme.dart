import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF00C9A7),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF00C9A7),
    ),
  );

  static LinearGradient get primaryGradient => _primaryGradient;

  static Gradient? get gradient => null;
}
