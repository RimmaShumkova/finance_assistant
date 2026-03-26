import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'phone_auth_screen.dart';
import 'otp_verification_screen.dart';
import 'main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Budget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/phone-auth': (context) => const PhoneAuthScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
        '/main': (context) => MainScreen.getScreen(),
      },
    );
  }
}