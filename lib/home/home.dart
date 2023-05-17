// home.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/categories.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 25, left: 15),
                child: Text('Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),
              Expanded(child: Categories(),)
            ]
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          backgroundColor: Colors.black,
          onPressed: () {},
          child: const Icon(Icons.add, size: 35,)
      ),
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
        child: BottomNavigationBar(backgroundColor: Colors.white, showSelectedLabels: false, showUnselectedLabels: false, selectedItemColor: Colors.blueAccent, unselectedItemColor: Colors.grey.withOpacity(0.5), items: const [
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home_rounded, size: 30)),
          BottomNavigationBarItem(label: 'Contacts', icon: Icon(Icons.contacts_outlined, size: 30)),
        ],),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          SizedBox(
              height: 45,
              width: 45,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('images/logo.jpg'),
              )
          ),
          const SizedBox(width: 10),
          const Text('Hi, impu!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),)
        ],
      ),
      actions: const [
        Icon(Icons.more_vert,
          color: Colors.black,
          size: 40,)
      ],
    );
  }
}