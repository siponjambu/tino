import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'ui/home/home_page.dart';
import 'ui/onboarding/onboarding_page.dart';

class App extends StatelessWidget {
  final bool hasWallet;

  const App({
    super.key,
    required this.hasWallet,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: hasWallet
          ? const HomePage()
          : const OnboardingPage(),
    );
  }
}