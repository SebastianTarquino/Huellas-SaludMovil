import 'package:flutter/material.dart';
import 'config/app_state.dart';
import 'pages/splash/splash_app.dart';
import 'theme/theme_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStateNotifier.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppStateNotifier.themeModeNotifier,
      builder: (context, currentThemeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppStateNotifier.localeNotifier,
          builder: (context, currentLocale, child) {
            return MaterialApp(
              title: 'Huellas y Salud Mobile',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: currentThemeMode,
              locale: currentLocale,
              home: const SplashScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}