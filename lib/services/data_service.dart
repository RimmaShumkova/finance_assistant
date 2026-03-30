import 'package:finance_assistant/models/expense_category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataService {
  static const String _incomeKey = 'budget_income';
  static const String _categoriesKey = 'budget_categories';

  Future<void> saveBudget(double income, List<ExpenseCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_incomeKey, income);
    
    List<String> categoriesJson = categories.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_categoriesKey, categoriesJson);
  }

  Future<(double?, List<ExpenseCategory>?)> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    
    final income = prefs.getDouble(_incomeKey);
    
    final categoriesJson = prefs.getStringList(_categoriesKey);
    if (categoriesJson == null) {
      return (income, null);
    }
    
    final categories = categoriesJson
        .map((jsonStr) => ExpenseCategory.fromJson(json.decode(jsonStr)))
        .toList();
    
    return (income, categories);
  }
  
  Future<void> clearBudget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_incomeKey);
    await prefs.remove(_categoriesKey);
  }
}