import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/expense_category.dart';
import '../services/api_service.dart';
import '../services/data_service.dart';
import '../widgets/expense_chart.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<ExpenseCategory> _categories = [];
  bool _isLoading = true;
  bool _didLoad = false;
  String _currentMonth = '';
  double? _income;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _currentMonth = _getCurrentMonth();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      _income = args['income'] as double?;
      _categories = List<ExpenseCategory>.from(args['categories'] as List);
      _isLoading = false;
    }
    _loadBudgetSummary(showLoader: args == null);
  }

  Future<void> _loadBudgetSummary({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    try {
      final summary = await _apiService.getBudgetSummary();
      if (!mounted) return;
      setState(() {
        _income = summary.monthlyIncome;
        _categories = summary.categories;
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

  String _getCurrentMonth() {
    final now = DateTime.now();
    final months = [
      'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
      'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'
    ];
    return months[now.month - 1];
  }

  void _onEditPressed() {
    Navigator.pushNamed(
      context,
      '/budget',
      arguments: {
        'initialIncome': _income,
        'initialCategories': _categories,
      },
    );
  }

  Future<void> _logout() async {
    await _apiService.clearSession();
    await DataService().clearBudget();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Текущие расходы',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
                fontSize: 18,
              ),
            ),
            Text(
              _currentMonth,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.yellow,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.black,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadBudgetSummary(),
          ),
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.yellow,
              ),
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildTotalStats(),
                const SizedBox(height: 16),
                if (_categories.isNotEmpty)
                  ExpenseChart(categories: _categories),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Расходы по категориям',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._categories.map((category) =>
                    _buildExpenseCard(category)),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 80),
              ],
            ),
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseCategory category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blackCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.yellow.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Color(category.color),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForCategory(category.name),
                        size: 14,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: category.spentPercentage,
            backgroundColor: AppTheme.grey.withOpacity(0.3),
            color: category.spent > category.budget ? AppTheme.red : AppTheme.yellow,
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${category.spent.toStringAsFixed(0)} ₽",
                      style: TextStyle(
                        color: category.spent > category.budget
                            ? AppTheme.red
                            : AppTheme.yellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: " / ${category.budget.toStringAsFixed(0)} ₽",
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${(category.spentPercentage * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: category.spent > category.budget
                      ? AppTheme.red
                      : AppTheme.yellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'продукты':
        return Icons.shopping_basket;
      case 'транспорт':
        return Icons.directions_car;
      case 'развлечения':
        return Icons.local_movies;
      case 'коммунальные услуги':
        return Icons.lightbulb;
      case 'накопления':
        return Icons.account_balance;
      default:
        return Icons.category;
    }
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildNavButton(
                  icon: Icons.receipt_long,
                  label: 'Операции',
                  onPressed: () => Navigator.pushNamed(context, '/transactions'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNavButton(
                  icon: Icons.flag,
                  label: 'Цели',
                  onPressed: () => Navigator.pushNamed(context, '/goals'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNavButton(
                  icon: Icons.notifications,
                  label: 'Уведомления',
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _buildNavButton(
              icon: Icons.edit,
              label: 'Редактировать бюджет',
              onPressed: _onEditPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.blackCard,
        foregroundColor: AppTheme.white,
        elevation: 0,
        side: BorderSide(
          color: AppTheme.yellow.withOpacity(0.5),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStats() {
    final totalSpent = _categories.fold(0.0, (sum, item) => sum + item.spent);
    final totalBudget = _categories.fold(0.0, (sum, item) => sum + item.budget);
    final totalRemaining = totalBudget - totalSpent;
    final totalPercentage = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    final currentDay = DateTime.now().day;
    final daysInMonth = DateTime.now().month == 2
        ? (DateTime.now().year % 4 == 0 ? 29 : 28)
        : [4, 6, 9, 11].contains(DateTime.now().month) ? 30 : 31;

    final dayProgress = currentDay / daysInMonth;
    final isOnTrack = totalPercentage <= dayProgress + 0.1;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.blackCard, AppTheme.blackSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.yellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Общая статистика',
                style: TextStyle(
                  color: AppTheme.greyLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnTrack
                      ? AppTheme.green.withOpacity(0.15)
                      : AppTheme.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOnTrack ? Icons.check_circle : Icons.warning_amber,
                      size: 12,
                      color: isOnTrack ? AppTheme.green : AppTheme.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnTrack ? 'По плану' : 'Перерасход',
                      style: TextStyle(
                        fontSize: 10,
                        color: isOnTrack ? AppTheme.green : AppTheme.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Потрачено',
                '${totalSpent.toStringAsFixed(0)} ₽',
                AppTheme.yellow,
              ),
              _buildStatItem(
                'Осталось',
                '${totalRemaining.toStringAsFixed(0)} ₽',
                totalRemaining < 0 ? AppTheme.red : AppTheme.green,
              ),
              _buildStatItem(
                'Бюджет',
                '${totalBudget.toStringAsFixed(0)} ₽',
                AppTheme.greyLight,
              ),
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
              Text(
                'Общий прогресс: ${(totalPercentage * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.greyLight,
                  fontSize: 12,
                ),
              ),
              Text(
                'День $currentDay из $daysInMonth',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
