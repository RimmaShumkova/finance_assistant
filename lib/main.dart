import 'package:flutter/material.dart';

import 'screens/budget_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/phone_auth_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/main_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/transactions_screen.dart';

import 'services/app_navigation.dart';
import 'services/push_notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await PushNotificationService.instance.initialize();
    await PushNotificationService.instance.registerCurrentDeviceIfSignedIn();
  } catch (error) {
    debugPrint('Failed to initialize push notifications: $error');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppNavigation.navigatorKey,
      title: 'Finance Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/phone-auth': (context) => const PhoneAuthScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
        '/main': (context) => MainScreen.getScreen(),
        '/budget': (context) => BudgetScreen(
          initialCategories: (ModalRoute.of(context)!.settings.arguments as Map?)?['initialCategories'],
          initialIncome: (ModalRoute.of(context)!.settings.arguments as Map?)?['initialIncome'],
        ),
        '/expenses': (context) => const ExpensesScreen(),
        '/goals': (context) => const GoalsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/transactions': (context) => const TransactionsScreen(),
      },
    );
  }
}
