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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'spent': spent,
      'budget': budget,
      'isLocked': isLocked,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      spent: json['spent'],
      budget: json['budget'],
      isLocked: json['isLocked'] ?? false,
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
    );
  }
}