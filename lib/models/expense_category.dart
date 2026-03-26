class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final int color;
  final double spent;
  final double budget;
  final List<Transaction> transactions;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.spent,
    required this.budget,
    required this.transactions,
  });

  double get remaining => budget - spent;
  double get spentPercentage => (spent / budget).clamp(0.0, 1.0);
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String categoryId;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
  });
}