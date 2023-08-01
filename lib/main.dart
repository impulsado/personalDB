import 'package:flutter/material.dart';
import 'package:personaldb/home/home.dart';
import 'package:personaldb/verification/register.dart';
import 'package:personaldb/verification/login.dart';
import 'package:personaldb/widgets/notifications_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationHandler.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static String? dbPassword;

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "personalDB",
      theme: ThemeData(),
      initialRoute: '/login',
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/home": (context) => const HomePage(),
      },
    );
  }
}
