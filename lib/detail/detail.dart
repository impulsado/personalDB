import 'package:flutter/material.dart';
import 'package:personaldb/models/my_category.dart';
import 'package:personaldb/home/home.dart';

class DetailPage extends StatelessWidget {
  final MyCategory myCategory;

  DetailPage(this.myCategory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: Text('Detail Page'),
        )
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()),);}
      ),
    );
  }
}