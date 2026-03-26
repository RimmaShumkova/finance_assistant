import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../theme/app_theme.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseCategory category;

  const ExpenseCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOverBudget = category.spentPercentage > 1.0;
    final isNearLimit = category.spentPercentage > 0.9 && category.spentPercentage <= 1.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.blackCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget 
              ? AppTheme.red.withOpacity(0.3) 
              : AppTheme.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(category.color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Потрачено: ${_formatMoney(category.spent)}',
                            style: TextStyle(
                              color: AppTheme.greyLight,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Осталось: ${_formatMoney(category.remaining)}',
                            style: TextStyle(
                              color: isOverBudget
                                  ? AppTheme.red
                                  : AppTheme.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(category.spentPercentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget 
                        ? AppTheme.red 
                        : AppTheme.yellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: category.spentPercentage.clamp(0.0, 1.0),
                backgroundColor: AppTheme.grey.withOpacity(0.3),
                color: isOverBudget 
                    ? AppTheme.red 
                    : Color(category.color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Бюджет: ${_formatMoney(category.budget)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey,
                  ),
                ),
                if (isOverBudget)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: AppTheme.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Бюджет превышен',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isNearLimit)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Осталось мало',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.yellow,
                        fontWeight: FontWeight.w600,
                      ),
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