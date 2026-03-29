import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../theme/app_theme.dart';
import '../theme/widget_styles.dart';

class ExpenseChart extends StatelessWidget {
  final List<ExpenseCategory> categories;

  const ExpenseChart({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalSpent = categories.fold(0.0, (sum, item) => sum + item.spent);
    final nonEmptyCategories = categories.where((c) => c.spent > 0).toList();

    return Container(
      margin: WidgetStyles.chartMargin,
      padding: WidgetStyles.chartPadding,
      decoration: WidgetStyles.chartContainerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Структура расходов', style: WidgetStyles.chartTitleStyle),
          const SizedBox(height: 16),
          if (totalSpent == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Нет данных о расходах', style: WidgetStyles.emptyChartStyle),
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
      height: WidgetStyles.pieChartSize,
      width: WidgetStyles.pieChartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(WidgetStyles.pieChartSize, WidgetStyles.pieChartSize),
            painter: PieChartPainter(categories: categories, total: total),
          ),
          Container(
            width: WidgetStyles.centerCircleSize,
            height: WidgetStyles.centerCircleSize,
            decoration: WidgetStyles.centerCircleDecoration,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${total.toStringAsFixed(0)}', style: WidgetStyles.centerAmountStyle),
                  Text('₽', style: WidgetStyles.centerCurrencyStyle),
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
                width: WidgetStyles.legendColorSize,
                height: WidgetStyles.legendColorSize,
                decoration: WidgetStyles.legendColorBox(category.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(category.name, style: WidgetStyles.legendTextStyle),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: WidgetStyles.legendPercentageBadge(category.color),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: WidgetStyles.legendPercentageStyle(category.color),
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
