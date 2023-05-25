import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personaldb/home/home.dart';
import 'package:personaldb/constants/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "personalDB",
      theme: Themes.light,
      darkTheme: Themes.light,
      themeMode: ThemeMode.light,
      home: HomePage(),
    );
  }
}

