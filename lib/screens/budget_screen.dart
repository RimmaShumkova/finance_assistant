import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/expense_category.dart';
import '../services/api_service.dart';
import '../services/data_service.dart';
import 'package:uuid/uuid.dart';

class BudgetScreen extends StatefulWidget {
  final List<ExpenseCategory>? initialCategories;
  final double? initialIncome;

  const BudgetScreen({Key? key, this.initialCategories, this.initialIncome}) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    if (text.length > 1 && text.startsWith('0')) {
      return oldValue;
    }

    return newValue;
  }
}

class _BudgetScreenState extends State<BudgetScreen> {
  double? income;
  List<Category> categories = [];
  final Uuid _uuid = Uuid();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    income = widget.initialIncome;

    if (widget.initialCategories != null && widget.initialCategories!.isNotEmpty) {
      categories = widget.initialCategories!.map((e) =>
        Category(
          code: e.code,
          name: e.name,
          kind: e.kind,
          percent: (e.budget / (income ?? 1)) * 100,
          isLocked: e.isLocked,
          color: e.color,
        )
      ).toList();
    } else {
      categories = [
        Category(code: 'groceries', name: "Продукты", kind: 'expense', percent: 25, color: 0xFFFF6B6B),
        Category(code: 'utilities', name: "Коммунальные услуги", kind: 'expense', percent: 15, color: 0xFF96CEB4),
        Category(code: 'entertainment', name: "Развлечения", kind: 'expense', percent: 10, color: 0xFF45B7D1),
        Category(code: 'transport', name: "Транспорт", kind: 'expense', percent: 10, color: 0xFF4ECDC4),
        Category(code: 'savings', name: "Накопления", kind: 'savings', percent: 20, color: 0xFFFFEAA7),
        Category(code: 'other', name: "Остальное", kind: 'other', percent: 20, color: 0xFFDDA0DD),
      ];
    }
  }

  double moneyFor(Category c) => income != null ? income! * c.percent / 100 : 0;

  void editPercent(int index) async {
    if (income == null) return;

    final result = await AppTheme.showCustomInputDialog(
      context: context,
      title: "Введите %",
      initialValue: categories[index].percent.toStringAsFixed(0),
      suffix: "%",
    );

    if (result == null) return;

    double lockedSum = categories
        .where((c) => c.isLocked && c != categories[index])
        .fold(0.0, (sum, c) => sum + c.percent);

    double maxAllowed = (100 - lockedSum).clamp(0, 100).toDouble();

    updatePercent(index, result.clamp(0, maxAllowed));
  }

  void editAmount(int index) async {
    if (income == null) return;

    final result = await AppTheme.showCustomInputDialog(
      context: context,
      title: "Введите сумму",
      initialValue: moneyFor(categories[index]).toInt().toString(),
      suffix: "₽",
    );

    if (result == null) return;

    double lockedSum = categories
        .where((c) => c.isLocked && c != categories[index])
        .fold(0.0, (sum, c) => sum + c.percent);

    double maxPercent = (100 - lockedSum).clamp(0, 100).toDouble();
    double maxMoney = income! * maxPercent / 100;

    double percent = (result.clamp(0, maxMoney) / income!) * 100;

    updatePercent(index, percent);
  }

  void updatePercent(int index, double value) {
    if (income == null) return;

    setState(() {
      categories[index].percent = value;

      double lockedSum = categories
          .where((c) => c.isLocked)
          .fold(0.0, (sum, c) => sum + c.percent);

      double remaining = (100 - lockedSum).clamp(0, 100);

      var unlocked = categories.where((c) => !c.isLocked).toList();
      if (unlocked.isEmpty) return;

      double otherSum = unlocked
          .where((c) => c != categories[index])
          .fold(0.0, (sum, c) => sum + c.percent);

      double rest = (remaining - categories[index].percent).clamp(0, remaining);

      for (var c in unlocked) {
        if (c != categories[index]) {
          c.percent = otherSum == 0
              ? rest / (unlocked.length - 1)
              : (c.percent / otherSum) * rest;
        }
      }
    });
  }

  void toggleLock(int index) {
    setState(() {
      categories[index].isLocked = !categories[index].isLocked;

      double lockedSum = categories
          .where((c) => c.isLocked)
          .fold(0.0, (sum, c) => sum + c.percent);

      double remaining = (100 - lockedSum).clamp(0, 100);

      var unlocked = categories.where((c) => !c.isLocked).toList();
      if (unlocked.isEmpty) return;

      double currentSum = unlocked.fold(0.0, (sum, c) => sum + c.percent);

      if (currentSum == 0) {
        double perCategory = remaining / unlocked.length;
        for (var c in unlocked) c.percent = perCategory;
      } else {
        for (var c in unlocked) {
          c.percent = (c.percent / currentSum) * remaining;
        }
      }
    });
  }

  void saveBudget() async {
    if (income == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppTheme.errorSnackBar("Сначала введите доход"));
      return;
    }

    List<ExpenseCategory> expenseCategories = categories.map((c) =>
        ExpenseCategory(
          id: _uuid.v4(),
          code: c.code,
          name: c.name,
          kind: c.kind,
          color: c.color,
          spent: 0,
          budget: moneyFor(c),
          transactions: [],
          isLocked: c.isLocked,
        )).toList();

    setState(() => _isSaving = true);
    try {
      await _apiService.updateBudgetSettings(
        monthlyIncome: income!,
        categories: expenseCategories,
      );

      final dataService = DataService();
      await dataService.saveBudget(income!, expenseCategories);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(error.toString()),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pushReplacementNamed(
      context,
      '/expenses',
      arguments: {
        'income': income,
        'categories': expenseCategories,
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
    final isEditingExistingBudget = widget.initialCategories != null;
    return PopScope(
      canPop: isEditingExistingBudget,
      child: Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          "Мой бюджет",
                          style: AppTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Выйти',
                        icon: const Icon(Icons.logout, color: AppTheme.grey),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    income != null ? "${income!.toInt()} ₽" : "0 ₽",
                    style: AppTheme.headlineLarge,
                  ),
                  if (income == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Введите доход для распределения бюджета",
                        style: AppTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.white),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  NoLeadingZeroFormatter(),
                ],
                decoration: AppTheme.inputDecoration(
                  hintText: "Введите доход",
                  suffixText: "₽",
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() => income = null);
                    return;
                  }

                  String cleaned = value.replaceFirst(RegExp(r'^0+'), '');

                  setState(() {
                    income = cleaned.isEmpty ? 0 : double.parse(cleaned);
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Container(
                decoration: AppTheme.darkContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];

                            double maxSlider = category.isLocked || income == null
                                ? category.percent
                                : (100 -
                                        categories
                                            .where((c) => c.isLocked)
                                            .fold(0.0, (sum, c) => sum + c.percent))
                                    .clamp(0, 100)
                                    .toDouble();

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: AppTheme.cardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            margin: const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: Color(category.color),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Text(category.name, style: AppTheme.titleSmall),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => toggleLock(index),
                                            child: Icon(
                                              category.isLocked
                                                  ? Icons.lock
                                                  : Icons.lock_open,
                                              size: 16,
                                              color: AppTheme.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () => editAmount(index),
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                              begin: 0, end: moneyFor(category)),
                                          duration: const Duration(milliseconds: 300),
                                          builder: (context, value, child) =>
                                              Text("${value.round()} ₽",
                                                  style: AppTheme.bodyMedium),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () => editPercent(index),
                                    child: Text(
                                      "${category.percent.toStringAsFixed(0)}%",
                                      style: AppTheme.bodyMedium,
                                    ),
                                  ),
                                  Slider(
                                    value: category.percent.clamp(0, maxSlider),
                                    min: 0,
                                    max: maxSlider,
                                    divisions: 100,
                                    activeColor: AppTheme.yellow,
                                    inactiveColor: AppTheme.grey,
                                    onChanged: category.isLocked || income == null
                                        ? null
                                        : (value) => updatePercent(index, value),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppTheme.yellowButtonMedium,
                          onPressed: _isSaving ? null : saveBudget,
                          child: _isSaving
                              ? AppTheme.smallProgress
                              : const Text("Сохранить"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class Category {
  String code;
  String name;
  String kind;
  double percent;
  bool isLocked;
  int color;

  Category({
    required this.code,
    required this.name,
    required this.kind,
    required this.percent,
    this.isLocked = false,
    required this.color,
  });
}
