import 'package:flutter/material.dart';

// auth flow
import 'welcome_screen.dart';
import 'phone_auth_screen.dart';
import 'otp_verification_screen.dart';
import 'main_screen.dart';

// expenses
import 'screens/expenses_screen.dart';

// theme
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

      // берём нормальную тему из первого варианта
      theme: AppTheme.darkTheme,

      // старт через auth
      initialRoute: '/',

      routes: {
        // auth flow
        '/': (context) => const WelcomeScreen(),
        '/phone-auth': (context) => const PhoneAuthScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
        '/main': (context) => MainScreen.getScreen(),

        // твои экраны
        '/expenses': (context) => const ExpensesScreen(),
      },
    );
  }
}
