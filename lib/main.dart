import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FitnessHubApp());
}

class FitnessHubApp extends StatelessWidget {
  const FitnessHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitnessHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      // Széles ablaknál (pl. Windows teszt) telefon szélességű oszlopba zárjuk az appot.
      builder: (context, child) => ColoredBox(
        color: Colors.black,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
