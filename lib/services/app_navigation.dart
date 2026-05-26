import 'package:flutter/material.dart';

class AppNavigation {
  AppNavigation._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static void resetToWelcome() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }
}
