class ExpenseCategory {
  final String id;
  final String name;
  final int color;
  final double spent;
  final double budget;
  final List<Transaction> transactions;
  bool isLocked;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.spent,
    required this.budget,
    required this.transactions,
    this.isLocked = false,
  });

  double get remaining => budget - spent;
  double get spentPercentage => budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

  ExpenseCategory copyWith({bool? isLocked}) {
    return ExpenseCategory(
      id: id,
      name: name,
      color: color,
      spent: spent,
      budget: budget,
      transactions: transactions,
      isLocked: isLocked ?? this.isLocked,
    );
  }
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