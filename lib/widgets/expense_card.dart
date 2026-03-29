import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../theme/app_theme.dart';
import '../theme/widget_styles.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseCategory category;

  const ExpenseCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOverBudget = category.spentPercentage > 1.0;
    final isNearLimit = category.spentPercentage > 0.9 && category.spentPercentage <= 1.0;
    
    return Container(
      margin: WidgetStyles.cardMargin,
      decoration: WidgetStyles.expenseCardDecoration(
        isOverBudget: isOverBudget,
        isNearLimit: isNearLimit,
      ),
      child: Padding(
        padding: WidgetStyles.cardPadding,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: WidgetStyles.iconSize,
                  height: WidgetStyles.iconSize,
                  decoration: WidgetStyles.categoryIconDecoration(category.color),
                  child: Center(
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: WidgetStyles.iconFontSize),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: WidgetStyles.categoryNameStyle),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Потрачено: ${_formatMoney(category.spent)}',
                            style: WidgetStyles.spentTextStyle,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Осталось: ${_formatMoney(category.remaining)}',
                            style: WidgetStyles.remainingTextStyle(isOverBudget),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(category.spentPercentage * 100).toInt()}%',
                  style: WidgetStyles.percentageTextStyle(isOverBudget),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: category.spentPercentage.clamp(0.0, 1.0),
                backgroundColor: AppTheme.grey.withOpacity(0.3),
                color: isOverBudget ? AppTheme.red : Color(category.color),
                minHeight: WidgetStyles.progressHeight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Бюджет: ${_formatMoney(category.budget)}',
                  style: AppTheme.bodySmall,
                ),
                if (isOverBudget)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: WidgetStyles.warningBadgeDecoration(AppTheme.red),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 12, color: AppTheme.red),
                        const SizedBox(width: 4),
                        Text(
                          'Бюджет превышен',
                          style: WidgetStyles.warningTextStyle.copyWith(color: AppTheme.red),
                        ),
                      ],
                    ),
                  )
                else if (isNearLimit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: WidgetStyles.warningBadgeDecoration(AppTheme.yellow),
                    child: Text(
                      'Осталось мало',
                      style: WidgetStyles.warningTextStyle.copyWith(color: AppTheme.yellow),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMoney(double amount) {
    return '${amount.toStringAsFixed(0)} ₽';
  }
}
