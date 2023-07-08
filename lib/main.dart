import 'package:flutter/material.dart';
import 'package:personaldb/home/home.dart';
import 'package:personaldb/initial_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "personalDB",
      theme: ThemeData(),
      home: InitialScreen(),
      routes: {
        '/home': (context) => HomePage(),
      },
    );
  }
}