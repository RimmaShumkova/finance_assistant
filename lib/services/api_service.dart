import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_category.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com'; // Замените на ваш API

  // Имитация API запроса
  Future<List<ExpenseCategory>> getTransactions() async {
    try {
      // Реальный API запрос:
      // final response = await http.get(
      //   Uri.parse('$baseUrl/transactions'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      // if (response.statusCode == 200) {
      //   return parseCategories(json.decode(response.body));
      // }

      // Имитация данных для демонстрации
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
        icon: '🍔',
        color: 0xFFFF6B6B,
        spent: 12500,
        budget: 15000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '2',
        name: 'Транспорт',
        icon: '🚗',
        color: 0xFF4ECDC4,
        spent: 3500,
        budget: 5000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '3',
        name: 'Развлечения',
        icon: '🎬',
        color: 0xFF45B7D1,
        spent: 4800,
        budget: 8000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '4',
        name: 'Коммуналка',
        icon: '💡',
        color: 0xFF96CEB4,
        spent: 6500,
        budget: 7000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '5',
        name: 'Здоровье',
        icon: '💊',
        color: 0xFFFFEAA7,
        spent: 2800,
        budget: 4000,
        transactions: [],
      ),
      ExpenseCategory(
        id: '6',
        name: 'Шопинг',
        icon: '🛍️',
        color: 0xFFDDA0DD,
        spent: 9200,
        budget: 10000,
        transactions: [],
      ),
    ];
  }

  // Обновление данных с сервера
  Future<void> refreshData() async {
    // Здесь можно добавить логику обновления
    await Future.delayed(const Duration(seconds: 1));
  }
}