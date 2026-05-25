import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ApiService _apiService = ApiService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _apiService.getTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(error.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Операции'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.yellow))
          : _transactions.isEmpty
              ? const Center(
                  child: Text('Операций пока нет', style: AppTheme.bodyLarge),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final item = _transactions[index];
                    final color = Color(
                      ExpenseCategory.colorForCode(item.categoryCode),
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardDecoration(withShadow: false),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.receipt_long, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.merchant?.isNotEmpty == true
                                      ? item.merchant!
                                      : item.description,
                                  style: AppTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: AppTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_categoryName(item.categoryCode)} • ${_formatDate(item.date)}',
                                  style: AppTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.amount.toStringAsFixed(0)} ₽',
                            style: const TextStyle(
                              color: AppTheme.yellow,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _categoryName(String code) {
    switch (code) {
      case 'groceries':
        return 'Продукты';
      case 'utilities':
        return 'Коммунальные услуги';
      case 'entertainment':
        return 'Развлечения';
      case 'transport':
        return 'Транспорт';
      case 'savings':
        return 'Накопления';
      default:
        return 'Остальное';
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day.$month';
  }
}
