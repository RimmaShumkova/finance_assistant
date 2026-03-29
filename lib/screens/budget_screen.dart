import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Category {
  String name;
  double percent;
  bool isLocked;
  Category({required this.name, required this.percent, this.isLocked = false});
}

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double? income;
  List<Category> categories = [
    Category(name: "Продукты", percent: 25),
    Category(name: "Коммунальные", percent: 15),
    Category(name: "Развлечения", percent: 10),
    Category(name: "Транспорт", percent: 10),
    Category(name: "Накопления", percent: 20),
    Category(name: "Остальное", percent: 20),
  ];

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
    double lockedSum = categories.where((c) => c.isLocked && c != categories[index]).fold(0.0, (sum, c) => sum + c.percent);
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
    double lockedSum = categories.where((c) => c.isLocked && c != categories[index]).fold(0.0, (sum, c) => sum + c.percent);
    double maxPercent = (100 - lockedSum).clamp(0, 100).toDouble();
    double maxMoney = income! * maxPercent / 100;
    double percent = (result.clamp(0, maxMoney) / income!) * 100;
    updatePercent(index, percent);
  }

  void updatePercent(int index, double value) {
    if (income == null) return;
    setState(() {
      categories[index].percent = value;
      double lockedSum = categories.where((c) => c.isLocked).fold(0.0, (sum, c) => sum + c.percent);
      double remaining = (100 - lockedSum).clamp(0, 100);
      var unlocked = categories.where((c) => !c.isLocked).toList();
      if (unlocked.isEmpty) return;
      double otherSum = unlocked.where((c) => c != categories[index]).fold(0.0, (sum, c) => sum + c.percent);
      double rest = (remaining - categories[index].percent).clamp(0, remaining);
      for (var c in unlocked) {
        if (c != categories[index]) {
          c.percent = otherSum == 0 ? rest / (unlocked.length - 1) : (c.percent / otherSum) * rest;
        }
      }
    });
  }

  void toggleLock(int index) {
    setState(() {
      categories[index].isLocked = !categories[index].isLocked;
      double lockedSum = categories.where((c) => c.isLocked).fold(0.0, (sum, c) => sum + c.percent);
      double remaining = (100 - lockedSum).clamp(0, 100);
      var unlocked = categories.where((c) => !c.isLocked).toList();
      if (unlocked.isEmpty) return;
      double currentSum = unlocked.fold(0.0, (sum, c) => sum + c.percent);
      if (currentSum == 0) {
        double perCategory = remaining / unlocked.length;
        for (var c in unlocked) c.percent = perCategory;
      } else {
        for (var c in unlocked) c.percent = (c.percent / currentSum) * remaining;
      }
    });
  }

  void saveBudget() {
    if (income == null) {
      ScaffoldMessenger.of(context).showSnackBar(AppTheme.errorSnackBar("Сначала введите доход"));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(AppTheme.successSnackBar("Бюджет сохранён"));
    Navigator.pushNamed(context, '/expenses');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Мой бюджет", style: AppTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(income != null ? "${income!.toInt()} ₽" : "0 ₽", style: AppTheme.headlineLarge),
                  if (income == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("Введите доход для распределения бюджета", style: AppTheme.bodySmall),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.white),
                decoration: AppTheme.inputDecoration(hintText: "Введите доход", suffixText: "₽"),
                onChanged: (value) => setState(() => income = double.tryParse(value)),
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
                                : (100 - categories.where((c) => c.isLocked).fold(0.0, (sum, c) => sum + c.percent)).clamp(0, 100).toDouble();
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
                                          Text(category.name, style: AppTheme.titleSmall),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => toggleLock(index),
                                            child: Icon(category.isLocked ? Icons.lock : Icons.lock_open, size: 16, color: AppTheme.grey),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () => editAmount(index),
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: 0, end: moneyFor(category)),
                                          duration: const Duration(milliseconds: 300),
                                          builder: (context, value, child) => Text("${value.round()} ₽", style: AppTheme.bodyMedium),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () => editPercent(index),
                                    child: Text("${category.percent.toStringAsFixed(0)}%", style: AppTheme.bodyMedium),
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: AppTheme.yellow,
                                      inactiveTrackColor: AppTheme.grey,
                                      thumbColor: Colors.black,
                                      overlayColor: AppTheme.yellowLight,
                                    ),
                                    child: Slider(
                                      value: category.percent.clamp(0, maxSlider),
                                      min: 0,
                                      max: maxSlider,
                                      divisions: 100,
                                      onChanged: category.isLocked || income == null ? null : (value) => updatePercent(index, value),
                                    ),
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
                          onPressed: saveBudget,
                          child: const Text("Сохранить"),
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
    );
  }
}
