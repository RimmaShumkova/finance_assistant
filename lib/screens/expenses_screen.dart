import 'package:flutter/material.dart';
import 'package:finance_assistant/services/api_service.dart';
import 'package:finance_assistant/models/expense_category.dart';
import 'package:finance_assistant/widgets/expense_card.dart';
import 'package:finance_assistant/widgets/expense_chart.dart';
import 'package:finance_assistant/theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ApiService _apiService = ApiService();
  List<ExpenseCategory> _categories = [];
  bool _isLoading = true;
  String? _error;
  String _currentMonth = '';

  @override
  void initState() {
    super.initState();
    _currentMonth = _getCurrentMonth();
    _loadData();
  }

  String _getCurrentMonth() {
    const months = ['январь', 'февраль', 'март', 'апрель', 'май', 'июнь', 'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'];
    return months[DateTime.now().month - 1];
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _categories = await _apiService.getTransactions();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async => _loadData();
  void _onEditPressed() => Navigator.pushNamed(context, '/budget');
  void _onSavingsPressed() => ScaffoldMessenger.of(context).showSnackBar(AppTheme.successSnackBar('Накопления'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Текущие расходы', style: AppTheme.appBarTitleStyle),
            Text(_currentMonth, style: AppTheme.appBarMonthStyle),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppTheme.yellow), onPressed: _refreshData, tooltip: 'Обновить'),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.yellow))
          : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppTheme.yellow,
                  backgroundColor: AppTheme.blackCard,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildTotalStats(),
                      const SizedBox(height: 16),
                      if (_categories.isNotEmpty) ExpenseChart(categories: _categories),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Расходы по категориям', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.white)),
                      ),
                      const SizedBox(height: 8),
                      ..._categories.map((category) => ExpenseCard(category: category)),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: ElevatedButton(onPressed: _onEditPressed, style: AppTheme.outlinedButton, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Редактировать')]))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: _onSavingsPressed, style: AppTheme.yellowButtonMedium, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.savings, size: 18), SizedBox(width: 8), Text('Накопления')]))),
        ],
      ),
    );
  }

  Widget _buildTotalStats() {
    final totalSpent = _categories.fold(0.0, (sum, item) => sum + item.spent);
    final totalBudget = _categories.fold(0.0, (sum, item) => sum + item.budget);
    final totalRemaining = totalBudget - totalSpent;
    final totalPercentage = (totalSpent / totalBudget).clamp(0.0, 1.0);
    final currentDay = DateTime.now().day;
    final daysInMonth = DateTime.now().month == 2 ? (DateTime.now().year % 4 == 0 ? 29 : 28) : [4, 6, 9, 11].contains(DateTime.now().month) ? 30 : 31;
    final isOnTrack = totalPercentage <= currentDay / daysInMonth + 0.1;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.gradientCard,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Общая статистика', style: TextStyle(color: AppTheme.greyLight, fontSize: 14, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: AppTheme.statusBadge(isSuccess: isOnTrack),
                child: Row(
                  children: [
                    Icon(isOnTrack ? Icons.check_circle : Icons.warning_amber, size: 12, color: isOnTrack ? AppTheme.green : AppTheme.red),
                    const SizedBox(width: 4),
                    Text(isOnTrack ? 'По плану' : 'Перерасход', style: TextStyle(fontSize: 10, color: isOnTrack ? AppTheme.green : AppTheme.red, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AppTheme.buildStatItem('Потрачено', '${totalSpent.toStringAsFixed(0)} ₽', AppTheme.yellow),
              AppTheme.buildStatItem('Осталось', '${totalRemaining.toStringAsFixed(0)} ₽', totalRemaining < 0 ? AppTheme.red : AppTheme.green),
              AppTheme.buildStatItem('Бюджет', '${totalBudget.toStringAsFixed(0)} ₽', AppTheme.greyLight),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalPercentage,
              backgroundColor: AppTheme.grey.withOpacity(0.3),
              color: totalPercentage > 1.0 ? AppTheme.red : AppTheme.yellow,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Общий прогресс: ${(totalPercentage * 100).toInt()}%', style: AppTheme.bodyMedium),
              Text('День $currentDay из $daysInMonth', style: AppTheme.bodyXSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.grey),
          const SizedBox(height: 16),
          const Text('Ошибка загрузки данных', style: TextStyle(fontSize: 18, color: AppTheme.white)),
          const SizedBox(height: 8),
          Text(_error ?? 'Неизвестная ошибка', style: AppTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadData, style: AppTheme.retryButton, child: const Text('Попробовать снова')),
        ],
      ),
    );
  }
}