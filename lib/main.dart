import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(const NutriBovApp());
}

class NutriBovApp extends StatelessWidget {
  const NutriBovApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriBov - Balanceamento Nutricional',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}