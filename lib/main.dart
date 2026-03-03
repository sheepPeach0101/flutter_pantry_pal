import 'package:flutter/material.dart';
import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/views/welcome.dart';
import 'package:PantryPal/views/signup.dart';
import 'package:PantryPal/views/navigation_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}
