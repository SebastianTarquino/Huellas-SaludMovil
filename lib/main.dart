import 'package:flutter/material.dart';
import 'pages/splash/splash_app.dart';
import 'theme/theme_app.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
    title: 'Flutter Demo App',
    theme: AppTheme.lightTheme(),
    darkTheme: AppTheme.darkTheme(),  
    themeMode: ThemeMode.system,
    home: const SplashScreen(),
    debugShowCheckedModeBanner: false,
   );
  }
}