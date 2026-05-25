import 'package:flutter/material.dart';
import '../services/api_service.dart';
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
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final summary = await _apiService.getBudgetSummary();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/expenses',
        (route) => false,
        arguments: {
          'income': summary.monthlyIncome,
          'categories': summary.categories,
        },
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'budget_not_configured') {
        Navigator.pushNamedAndRemoveUntil(context, '/budget', (route) => false);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(error.message),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/budget', (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(error.toString()),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/budget', (route) => false);
    }
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
