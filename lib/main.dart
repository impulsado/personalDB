import 'package:flutter/material.dart';
import 'package:personaldb/home/home.dart';
import 'package:personaldb/verification/register.dart';
import 'package:personaldb/verification/login.dart';
import 'package:personaldb/widgets/notifications_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static String? dbPassword;
  static String? notificationPayload;

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationHandler.init();
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "personalDB",
      theme: ThemeData(),
      initialRoute: '/login',
      navigatorKey: navigatorKey, // Here, you pass the navigatorKey
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/home": (context) => const HomePage(),
      },
    );
  }
}
