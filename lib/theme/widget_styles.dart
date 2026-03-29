import 'package:flutter/material.dart';
import 'app_theme.dart';

class WidgetStyles {
  // ==================== СТИЛИ ДЛЯ EXPENSE CARD ====================
  
  static BoxDecoration expenseCardDecoration({
    required bool isOverBudget,
    required bool isNearLimit,
  }) {
    Color borderColor;
    if (isOverBudget) {
      borderColor = AppTheme.red.withOpacity(0.3);
    } else {
      borderColor = AppTheme.grey.withOpacity(0.2);
    }
    
    return BoxDecoration(
      color: AppTheme.blackCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: 1),
    );
  }
  
  static BoxDecoration categoryIconDecoration(int color) {
    return BoxDecoration(
      color: Color(color).withOpacity(0.15),
      borderRadius: BorderRadius.circular(25),
    );
  }
  
  static const TextStyle categoryNameStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppTheme.white,
  );
  
  static const TextStyle spentTextStyle = TextStyle(
    color: AppTheme.greyLight,
    fontSize: 12,
  );
  
  static TextStyle remainingTextStyle(bool isOverBudget) {
    return TextStyle(
      color: isOverBudget ? AppTheme.red : AppTheme.green,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
  }
  
  static TextStyle percentageTextStyle(bool isOverBudget) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isOverBudget ? AppTheme.red : AppTheme.yellow,
    );
  }
  
  static BoxDecoration warningBadgeDecoration(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    );
  }
  
  static const TextStyle warningTextStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
  
  // ==================== СТИЛИ ДЛЯ EXPENSE CHART ====================
  
  static BoxDecoration chartContainerDecoration = BoxDecoration(
    color: AppTheme.blackCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppTheme.grey.withOpacity(0.2), width: 1),
  );
  
  static const TextStyle chartTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppTheme.white,
  );
  
  static const TextStyle emptyChartStyle = TextStyle(
    color: AppTheme.grey,
  );
  
  static BoxDecoration centerCircleDecoration = BoxDecoration(
    color: AppTheme.blackCard,
    shape: BoxShape.circle,
    border: Border.all(color: AppTheme.grey.withOpacity(0.3), width: 1),
  );
  
  static const TextStyle centerAmountStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppTheme.white,
  );
  
  static const TextStyle centerCurrencyStyle = TextStyle(
    fontSize: 12,
    color: AppTheme.yellow,
    fontWeight: FontWeight.w600,
  );
  
  static BoxDecoration legendColorBox(int color) {
    return BoxDecoration(
      color: Color(color),
      borderRadius: BorderRadius.circular(2),
      boxShadow: [
        BoxShadow(
          color: Color(color).withOpacity(0.5),
          blurRadius: 2,
        ),
      ],
    );
  }
  
  static const TextStyle legendTextStyle = TextStyle(
    fontSize: 12,
    color: AppTheme.white,
    fontWeight: FontWeight.w500,
  );
  
  static BoxDecoration legendPercentageBadge(int color) {
    return BoxDecoration(
      color: Color(color).withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    );
  }
  
  static TextStyle legendPercentageStyle(int color) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Color(color),
    );
  }
  
  // ==================== КОНСТАНТЫ ====================
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets chartPadding = EdgeInsets.all(16);
  static const EdgeInsets chartMargin = EdgeInsets.all(16);
  static const double iconSize = 50;
  static const double iconFontSize = 24;
  static const double pieChartSize = 150;
  static const double centerCircleSize = 70;
  static const double legendColorSize = 12;
  static const double progressHeight = 8;
  static const EdgeInsets warningBadgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
}
