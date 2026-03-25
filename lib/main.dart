import 'package:flutter/material.dart';
import 'budget_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Budget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BudgetScreen(),
    );
  }
}
