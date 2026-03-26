import 'package:flutter/material.dart';
import 'phone_auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color yellow = const Color(0xFFFFD700);
    
    return Scaffold(
      backgroundColor: Colors.black,
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
                      // Логотип
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: yellow.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 50,
                          color: yellow,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Название
                      const Text(
                        'Smart Budget',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Умный финансовый помощник',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Функционал приложения
                      _buildFeatureItem(
                        icon: Icons.pie_chart,
                        title: 'Распределение бюджета',
                        description: 'Настройте проценты для каждой категории. Сумма автоматически контролируется (100%)',
                        color: yellow,
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureItem(
                        icon: Icons.trending_down,
                        title: 'Контроль расходов',
                        description: 'Отслеживайте потраченные средства и остаток по каждой категории',
                        color: yellow,
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureItem(
                        icon: Icons.show_chart,
                        title: 'Визуальная аналитика',
                        description: 'Графики и диаграммы для наглядного анализа ваших финансов',
                        color: yellow,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Кнопка начала
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
                    );
                  },
                  child: const Text(
                    'Начать',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}