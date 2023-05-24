import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper.dart';

class DetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  DetailPage(this.myCategory, {this.id});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isLoading = true;

  _submitNote(BuildContext context) async {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      if (widget.id != null) {
        await SQLHelper.updateItem(widget.id!, _titleController.text, _noteController.text);
      } else {
        await SQLHelper.createItem(widget.myCategory.title ?? "Error", _titleController.text, _noteController.text);
      }
      _titleController.clear();
      _noteController.clear();
      Navigator.pop(context, 'refresh');
    }
  }

  _loadNote() async {
    if (widget.id != null) {
      List<Map<String, dynamic>> items = await SQLHelper.getItem(widget.id!);
      if (items.length > 0) {
        setState(() {
          _titleController.text = items[0]['title'] ?? '';
          _noteController.text = items[0]['description'] ?? '';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.only(left:25, right:25, top: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.myCategory.title ?? "Add Note", style: headingStyle(color: Colors.black),),
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
      floatingActionButton: MyButton(
        label: "Submit",
        onTap: () => _submitNote(context),
        bgColor: widget.myCategory.bgColor ?? Colors.black,
        iconColor: widget.myCategory.iconColor ?? Colors.white,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: widget.myCategory.bgColor,
      elevation: 0,
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onTap: () {Navigator.pop(context);},
      ),
    );
  }
}