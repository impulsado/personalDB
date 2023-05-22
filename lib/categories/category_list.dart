import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/detail/detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: CategoryList(MyCategory()),
    );
  }
}

class CategoryList extends StatelessWidget {
  final MyCategory myCategory;

  const CategoryList(this.myCategory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Text('This is the ${myCategory.title} category'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: MyButton(
        label: "+ Add Note",
        bgColor: myCategory.bgColor ?? Colors.black,
        iconColor: myCategory.iconColor ?? Colors.white,
        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(myCategory),),);
      },),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: myCategory.bgColor,
      elevation: 0,
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onTap: () {Navigator.pop(context);},
      ),
    );
  }
}