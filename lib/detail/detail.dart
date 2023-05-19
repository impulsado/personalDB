import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart'; // ensure this is the correct import for your Themes class
import 'package:personaldb/models/my_category.dart';
import 'package:personaldb/home/home.dart';
import 'package:personaldb/widgets/input_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: DetailPage(MyCategory()), // ensure you pass an instance of MyCategory to DetailPage
    );
  }
}

class DetailPage extends StatelessWidget {
  final MyCategory myCategory;
  final TextEditingController _titleController = TextEditingController();

  DetailPage(this.myCategory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        padding: const EdgeInsets.only(left:25, right:25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(myCategory.title ?? "Add Note", style: headingStyle,),
              MyInputField(title: "Title", hint: "Enter title here.", controller: _titleController),
              MyInputField(title: "Note", hint: "Enter note here.", controller: _titleController),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        backgroundColor: Colors.black,
        onPressed: () {},
        child: const Icon(Icons.add, size: 35,)
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