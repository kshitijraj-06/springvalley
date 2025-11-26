import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const SpringValleyApp());
}

class SpringValleyApp extends StatelessWidget {
  const SpringValleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spring Valley',
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}