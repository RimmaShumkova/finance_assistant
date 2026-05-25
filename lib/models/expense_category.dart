class ExpenseCategory {
  final String id;
  final String code;
  final String name;
  final String kind;
  final int color;
  final double spent;
  final double budget;
  final List<Transaction> transactions;
  final List<String> alerts;
  bool isLocked;

  ExpenseCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.kind,
    required this.color,
    required this.spent,
    required this.budget,
    required this.transactions,
    this.alerts = const [],
    this.isLocked = false,
  });

  double get remaining => budget - spent;

  double get spentPercentage {
    return budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
  }

  String get icon => code.isNotEmpty ? code[0].toUpperCase() : '*';

  ExpenseCategory copyWith({bool? isLocked}) {
    return ExpenseCategory(
      id: id,
      code: code,
      name: name,
      kind: kind,
      color: color,
      spent: spent,
      budget: budget,
      transactions: transactions,
      alerts: alerts,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'kind': kind,
      'color': color,
      'spent': spent,
      'budget': budget,
      'alerts': alerts,
      'isLocked': isLocked,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      code: json['code'] as String? ?? 'other',
      name: json['name'] as String,
      kind: json['kind'] as String? ?? 'expense',
      color: json['color'] as int,
      spent: _readMoney(json['spent']),
      budget: _readMoney(json['budget']),
      alerts: ((json['alerts'] ?? const []) as List)
          .map((item) => item.toString())
          .toList(),
      isLocked: json['isLocked'] as bool? ?? false,
      transactions: ((json['transactions'] ?? const []) as List)
          .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ExpenseCategory.fromBudgetSummary(Map<String, dynamic> json) {
    final code = json['code'] as String;
    return ExpenseCategory(
      id: code,
      code: code,
      name: json['name'] as String,
      kind: json['kind'] as String? ?? 'expense',
      color: colorForCode(code),
      spent: _readMoney(json['spent_amount']),
      budget: _readMoney(json['limit_amount']),
      alerts: ((json['alerts'] ?? const []) as List)
          .map((item) => item is Map<String, dynamic>
              ? (item['message'] ?? '').toString()
              : item.toString())
          .where((message) => message.isNotEmpty)
          .toList(),
      transactions: const [],
    );
  }

  static int colorForCode(String code) {
    switch (code) {
      case 'groceries':
        return 0xFFFF6B6B;
      case 'utilities':
        return 0xFF96CEB4;
      case 'entertainment':
        return 0xFF45B7D1;
      case 'transport':
        return 0xFF4ECDC4;
      case 'savings':
        return 0xFFFFEAA7;
      default:
        return 0xFFDDA0DD;
    }
  }
}

class Transaction {
  final String id;
  final String? externalId;
  final String description;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String categoryCode;
  final String? merchant;
  final String? mcc;

  Transaction({
    required this.id,
    this.externalId,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
    String? categoryCode,
    this.merchant,
    this.mcc,
  }) : categoryCode = categoryCode ?? categoryId;

  factory Transaction.fromApi(Map<String, dynamic> json) {
    final categoryCode = json['category_code'] as String;
    return Transaction(
      id: json['id'] as String,
      externalId: json['external_id'] as String?,
      description: json['description'] as String,
      amount: _readMoney(json['amount']),
      date: DateTime.parse(json['occurred_at'] as String),
      categoryId: categoryCode,
      categoryCode: categoryCode,
      merchant: json['merchant'] as String?,
      mcc: json['mcc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'externalId': externalId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'categoryCode': categoryCode,
      'merchant': merchant,
      'mcc': mcc,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      externalId: json['externalId'] as String?,
      description: json['description'] as String,
      amount: _readMoney(json['amount']),
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String,
      categoryCode: json['categoryCode'] as String? ?? json['categoryId'] as String,
      merchant: json['merchant'] as String?,
      mcc: json['mcc'] as String?,
    );
  }
}

class FinancialGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double progressPercent;
  final double recommendedMonthlyAmount;
  final String status;

  const FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercent,
    required this.recommendedMonthlyAmount,
    required this.status,
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: _readMoney(json['target_amount']),
      currentAmount: _readMoney(json['current_amount']),
      progressPercent: _readMoney(json['progress_percent']),
      recommendedMonthlyAmount: _readMoney(json['recommended_monthly_amount']),
      status: json['status'] as String,
    );
  }
}

class BudgetNotification {
  final String id;
  final String categoryCode;
  final int threshold;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const BudgetNotification({
    required this.id,
    required this.categoryCode,
    required this.threshold,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory BudgetNotification.fromJson(Map<String, dynamic> json) {
    return BudgetNotification(
      id: json['id'] as String,
      categoryCode: json['category_code'] as String,
      threshold: json['threshold'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

double _readMoney(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}
