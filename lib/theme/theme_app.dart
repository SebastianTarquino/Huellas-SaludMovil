import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Paleta de colores actualizada
  static const Color primaryPurple = Color(0xFF7E57C2);    // 🟣 Primario
  static const Color secondaryLavender = Color(0xFFD1C4E9); // 🔵 Secundario
  static const Color backgroundLight = Color(0xFFF5F3F9);  // ⚪ Fondo general
  static const Color activePurple = Color(0xFF9575CD);      // 🔘 Activos
  static const Color successGreen = Color(0xFF81C784);      // 🟢 Éxito
  static const Color errorRed = Color(0xFFE57373);          // 🔴 Error
  static const Color textDark = Color(0xFF4A148C);          // ⚫ Texto fuerte
  static const Color textGrey = Color(0xFF888888);          // ⚪ Texto secundario

  // 🌞 Tema claro
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        secondary: secondaryLavender,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: activePurple,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activePurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        labelStyle: const TextStyle(color: textDark),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: textGrey,
        ),
      ),
    );
  }

  // 🌙 Tema oscuro
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: textDark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: textDark,
        secondary: secondaryLavender,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: textDark,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: activePurple,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activePurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: activePurple, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
    );
  }
}
