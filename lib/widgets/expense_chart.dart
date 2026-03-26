import 'package:flutter/material.dart';
import '../models/expense_category.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Структура расходов',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (totalSpent == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Нет данных о расходах'),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₽',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
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
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
    
    for (var category in categories) {
      final sweepAngle = (category.spent / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = Color(category.color)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}