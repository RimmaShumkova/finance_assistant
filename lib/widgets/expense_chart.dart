import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../theme/app_theme.dart';

class ExpenseChart extends StatelessWidget {
  final List<ExpenseCategory> categories;

  const ExpenseChart({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalSpent = categories.fold(0.0, (sum, item) => sum + item.spent);
    final nonEmptyCategories =
        categories.where((c) => c.spent > 0).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blackCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Структура расходов',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 16),
          if (totalSpent == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Нет данных о расходах',
                  style: TextStyle(
                    color: AppTheme.grey,
                  ),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildPieChart(context, nonEmptyCategories, totalSpent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildLegend(nonEmptyCategories, totalSpent),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, List<ExpenseCategory> categories, double total) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(150, 150),
            painter: PieChartPainter(categories: categories, total: total),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.blackCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  Text(
                    '₽',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.yellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<ExpenseCategory> categories, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        final percentage = (category.spent / total * 100);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(category.color),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Color(category.color).withOpacity(0.5),
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(category.color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(category.color),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<ExpenseCategory> categories;
  final double total;

  PieChartPainter({required this.categories, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -90 * (3.14159 / 180);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (var category in categories) {
      final sweepAngle = (category.spent / total) * 2 * 3.14159;
      
      // Основной сегмент
      final paint = Paint()
        ..color = Color(category.color)
        ..style = PaintingStyle.fill
        ..strokeWidth = 0;
      
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      // Добавляем тонкую обводку для контраста
      final strokePaint = Paint()
        ..color = AppTheme.blackCard
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        sweepAngle,
        true,
        strokePaint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Рисуем внешнюю обводку
    final outlinePaint = Paint()
      ..color = AppTheme.yellow.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawCircle(center, radius, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}