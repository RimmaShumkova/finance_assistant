import 'package:flutter/material.dart';

import 'screens/budget_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/phone_auth_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/main_screen.dart';
import 'screens/expenses_screen.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Assistant',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.darkTheme,

      initialRoute: '/',

      routes: {
        // auth flow
        '/': (context) => const WelcomeScreen(),
        '/phone-auth': (context) => const PhoneAuthScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
        '/main': (context) => MainScreen.getScreen(),

        // screens
        '/budget': (context) => BudgetScreen(),
        '/expenses': (context) => const ExpensesScreen(),
      },
    );
  }
}
