import 'package:flutter/material.dart';
import 'package:personaldb/home/home.dart';
import 'package:personaldb/verification/register.dart';
import 'package:personaldb/verification/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static String? dbPassword;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "personalDB",
      theme: ThemeData(),
      initialRoute: '/login', // Cambiamos esta línea
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
