import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: DetailPage(MyCategory()),
    );
  }
}

class DetailPage extends StatelessWidget {
  final MyCategory myCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DetailPage(this.myCategory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.only(left:25, right:25, top: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(myCategory.title ?? "Add Note", style: headingStyle(color: Colors.black),),
                    MyInputField(title: "Title", hint: "Enter title here.", controller: _titleController, height: 50),
                    MyInputField(title: "Note", hint: "Enter note here.", controller: _noteController, height: 200),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: MyButton(label: "Submit", onTap: ()=>null, bgColor: myCategory.bgColor ?? Colors.black, iconColor: myCategory.iconColor ?? Colors.white,),
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