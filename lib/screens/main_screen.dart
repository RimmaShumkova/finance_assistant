import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

abstract class MainScreen {
  static Widget getScreen() => const PlaceholderScreen();
}

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({super.key});
  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/budget');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: AppTheme.iconCircle,
              child: const Icon(Icons.check_circle_outline, size: 50, color: AppTheme.yellow),
            ),
            const SizedBox(height: 24),
            const Text('Успешный вход!', style: AppTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
