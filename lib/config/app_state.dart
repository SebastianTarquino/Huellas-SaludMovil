import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateNotifier {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.dark);
  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(const Locale('es', 'ES'));

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 🎨 Cargar Tema Guardado
    final themeStr = prefs.getString('pref_theme_mode') ?? 'Oscuro';
    if (themeStr == 'Claro') {
      themeModeNotifier.value = ThemeMode.light;
    } else if (themeStr == 'Oscuro') {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.system;
    }

    // 🌐 Cargar Idioma Guardado
    final langStr = prefs.getString('pref_language') ?? 'Español';
    if (langStr == 'English') {
      localeNotifier.value = const Locale('en', 'US');
    } else {
      localeNotifier.value = const Locale('es', 'ES');
    }
  }

  static Future<void> updateTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_theme_mode', themeName);

    if (themeName == 'Claro') {
      themeModeNotifier.value = ThemeMode.light;
    } else if (themeName == 'Oscuro') {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.system;
    }
  }

  static Future<void> updateLanguage(String langName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_language', langName);

    if (langName == 'English') {
      localeNotifier.value = const Locale('en', 'US');
    } else {
      localeNotifier.value = const Locale('es', 'ES');
    }
  }
}
