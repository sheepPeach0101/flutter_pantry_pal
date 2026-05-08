import 'package:flutter/material.dart';
import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/utils/auth_notifier.dart';
import 'package:PantryPal/views/welcome.dart';
import 'package:PantryPal/views/signup.dart';
import 'package:PantryPal/views/login.dart';
import 'package:PantryPal/views/navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 启动时检查本地是否有 Token，决定初始路由
  final hasToken = await AuthNotifier.instance.tryAutoLogin();
  final initialRoute = hasToken ? '/home' : '/welcome';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}
