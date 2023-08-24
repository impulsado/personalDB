// home.dart
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/widgets/categories.dart';
import 'package:personaldb/contacts/contacts.dart';
import 'package:personaldb/search/search.dart';
import 'package:personaldb/main.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  runApp(const HomeApp());
}

class HomeApp extends StatelessWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
      const Contacts(),
    ];
    if (MyApp.dbPassword != null) {
      _screens.add(Search(password: MyApp.dbPassword!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex < _screens.length ? _screens[_currentIndex] : const CircularProgressIndicator(),
      //backgroundColor: Colors.transparent,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: GNav(
              haptic: false,
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              duration: const Duration(milliseconds: 400),
              tabActiveBorder: Border.all(color: Colors.black, width: 1),
              color: Colors.grey[500],
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: "Home",
                ),
                GButton(
                  icon: Icons.contacts_outlined,
                  text: "CRM",
                ),
                GButton(
                  icon: Icons.search,
                  text: "Search",
                ),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
