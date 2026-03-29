import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_category.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com';

  Future<List<ExpenseCategory>> getTransactions() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return _getMockData();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  List<ExpenseCategory> _getMockData() {
    return [
      ExpenseCategory(
        id: '1',
        name: 'Продукты',
        color: 0xFFFF6B6B,
        spent: 12500,
        budget: 15000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '2',
        name: 'Транспорт',
        color: 0xFF4ECDC4,
        spent: 3500,
        budget: 5000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '3',
        name: 'Развлечения',
        color: 0xFF45B7D1,
        spent: 4800,
        budget: 8000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '4',
        name: 'Коммунальные услуги',
        color: 0xFF96CEB4,
        spent: 6500,
        budget: 7000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '5',
        name: 'Накопления',
        color: 0xFFFFEAA7,
        spent: 2800,
        budget: 4000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '6',
        name: 'Остальное',
        color: 0xFFDDA0DD,
        spent: 9200,
        budget: 10000,
        transactions: [],
      ),
    ];
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}