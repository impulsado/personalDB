// home.dart
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/widgets/categories.dart';
import 'package:personaldb/contacts/contacts.dart';
import 'package:personaldb/search/search.dart';
import 'package:personaldb/main.dart';

void main() {
  runApp(const HomeApp());
}

class HomeApp extends StatelessWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens = [
      Categories(),
      Contacts(),
    ];
    if (MyApp.dbPassword != null) {
      _screens.add(Search(password: MyApp.dbPassword!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex < _screens.length ? _screens[_currentIndex] : CircularProgressIndicator(),
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 5, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home_rounded, size: 30)),
            BottomNavigationBarItem(label: "Contacts", icon: Icon(Icons.contacts_outlined, size: 30)),
            BottomNavigationBarItem(label: "Search", icon: Icon(Icons.search, size: 30)),
          ],
        ),
      ),
    );
  }
}
