import 'package:flutter/material.dart';

class Category {
  String name;
  double percent;

  Category({required this.name, required this.percent});
}

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double income = 100000;

  List<Category> categories = [
    Category(name: "Продукты", percent: 25),
    Category(name: "Коммунальные", percent: 15),
    Category(name: "Развлечения", percent: 10),
    Category(name: "Транспорт", percent: 10),
    Category(name: "Накопления", percent: 20),
    Category(name: "Остальное", percent: 20), // последняя категория
  ];

  double get totalPercent =>
      categories.fold(0, (sum, item) => sum + item.percent);

  double moneyFor(Category c) => income * c.percent / 100;

  // Автоподстройка последней категории
  void updatePercent(int index, double value) {
    setState(() {
      final int lastIndex = categories.length - 1;
      if (index == lastIndex) {
        // Последнюю категорию менять вручную нельзя
        return;
      }

      categories[index].percent = value;

      double sumOther = categories
          .asMap()
          .entries
          .where((e) => e.key != lastIndex)
          .fold(0.0, (sum, e) => sum + e.value.percent);

      categories[lastIndex].percent = (100 - sumOther).clamp(0, 100);
    });
  }

  void saveBudget() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Бюджет сохранён")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Распределение бюджета"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ввод дохода
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Месячный доход",
                border: OutlineInputBorder(),
                suffixText: "₽",
              ),
              onChanged: (value) {
                setState(() {
                  income = double.tryParse(value) ?? 0;
                });
              },
            ),

            SizedBox(height: 16),

            // Категории
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${category.percent.toStringAsFixed(0)}%"),
                              // Плавная анимация
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    begin: 0, end: moneyFor(category)),
                                duration: Duration(milliseconds: 300),
                                builder: (context, value, child) {
                                  return Text(
                                    "${value.toInt()} ₽",
                                    style: TextStyle(color: Colors.grey),
                                  );
                                },
                              ),
                            ],
                          ),

                          Slider(
                            value: category.percent,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            onChanged: (value) => updatePercent(index, value),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Сумма процентов
            Text(
              "Сумма: ${totalPercent.toStringAsFixed(0)}%",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            // Кнопка
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: saveBudget,
                child: Text("Сохранить бюджет"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
