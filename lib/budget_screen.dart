import 'package:flutter/material.dart';

class Category {
  String name;
  double percent;
  bool isLocked;

  Category({
    required this.name,
    required this.percent,
    this.isLocked = false,
  });
}

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double? income; // теперь nullable
  final Color yellow = Color(0xFFFFD700);

  List<Category> categories = [
    Category(name: "Продукты", percent: 25),
    Category(name: "Коммунальные", percent: 15),
    Category(name: "Развлечения", percent: 10),
    Category(name: "Транспорт", percent: 10),
    Category(name: "Накопления", percent: 20),
    Category(name: "Остальное", percent: 20),
  ];

  double moneyFor(Category c) => income != null ? income! * c.percent / 100 : 0;

  // 🔹 Обновление процентов без автоматической фиксации
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
          if (otherSum == 0) {
            c.percent = rest / (unlocked.length - 1);
          } else {
            c.percent = (c.percent / otherSum) * rest;
          }
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

  void saveBudget() {
    if (income == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Сначала введите доход")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Бюджет сохранён")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Верхний блок (доход)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Мой бюджет",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    income != null ? "${income!.toInt()} ₽" : "0 ₽",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (income == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Введите доход для распределения бюджета",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            // Ввод дохода
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Введите доход",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixText: "₽",
                  suffixStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  setState(() {
                    income = double.tryParse(value);
                  });
                },
              ),
            ),

            SizedBox(height: 16),

            // Белый блок с категориями
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
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
                                : ((100 -
                                            categories
                                                .where((c) => c.isLocked)
                                                .fold(0.0,
                                                    (sum, c) => sum + c.percent))
                                        .clamp(0, 100))
                                    .toDouble();

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => toggleLock(index),
                                            child: Icon(
                                              category.isLocked
                                                  ? Icons.lock
                                                  : Icons.lock_open,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                            begin: 0, end: moneyFor(category)),
                                        duration: Duration(milliseconds: 300),
                                        builder: (context, value, child) {
                                          return Text(
                                            "${value.toInt()} ₽",
                                            style:
                                                TextStyle(color: Colors.grey[700]),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "${category.percent.toStringAsFixed(0)}%",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: yellow,
                                      inactiveTrackColor: Colors.grey[300],
                                      thumbColor: Colors.black,
                                      overlayColor: yellow.withOpacity(0.2),
                                    ),
                                    child: Slider(
                                      value: category.percent,
                                      min: 0,
                                      max: maxSlider,
                                      divisions: 100,
                                      onChanged: category.isLocked || income == null
                                          ? null
                                          : (value) => updatePercent(index, value),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellow,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: saveBudget,
                          child: Text(
                            "Сохранить",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
