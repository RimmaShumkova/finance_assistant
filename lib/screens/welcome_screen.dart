import 'package:flutter/material.dart';
import 'phone_auth_screen.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: AppTheme.iconCircle,
                        child: Icon(Icons.account_balance_wallet, size: 50, color: AppTheme.yellow),
                      ),
                      const SizedBox(height: 32),
                      const Text('Smart Budget', style: AppTheme.titleLarge),
                      const SizedBox(height: 16),
                      Text('Умный финансовый помощник', style: AppTheme.bodyLarge),
                      const SizedBox(height: 48),
                      _buildFeatureItem(
                        icon: Icons.pie_chart,
                        title: 'Распределение бюджета',
                        description: 'Настройте проценты для каждой категории. Сумма автоматически контролируется (100%)',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureItem(
                        icon: Icons.trending_down,
                        title: 'Контроль расходов',
                        description: 'Отслеживайте потраченные средства и остаток по каждой категории',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureItem(
                        icon: Icons.show_chart,
                        title: 'Визуальная аналитика',
                        description: 'Графики и диаграммы для наглядного анализа ваших финансов',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppTheme.yellowButtonLarge,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
                    );
                  },
                  child: const Text('Начать', style: AppTheme.buttonLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: AppTheme.cardDecoration(radius: 12, withShadow: false),
          child: Icon(icon, color: AppTheme.yellow, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(description, style: AppTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}