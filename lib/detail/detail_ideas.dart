import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_ideas.dart';
import 'package:personaldb/widgets/date_picker.dart';
import 'package:personaldb/widgets/field_autocomplete.dart';
import 'package:personaldb/main.dart';

class IdeasDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  IdeasDetailPage(this.myCategory, {this.id});

  @override
  _IdeasDetailPageState createState() => _IdeasDetailPageState();
}

class _IdeasDetailPageState extends State<IdeasDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');

  bool _isLoading = true;

  _submitNote(BuildContext context) async {
    if (_titleController.text.isNotEmpty) {

      if(MyApp.dbPassword == null) {
        throw ArgumentError("La contraseña de la base de datos es nula");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      final data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "date": _dateController.text,
        "category": _categoryController.text
      };
      if (widget.id != null) {
        await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
      } else {
        await dbHelper.createItem(data,MyApp.dbPassword!);
      }
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
      _categoryController.clear();
      Navigator.pop(context, "refresh");
    } else {
    }
  }

  _loadNote() async {
    if (widget.id != null) {
      if(MyApp.dbPassword == null) {
        throw ArgumentError("La contraseña de la base de datos es nula");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);
      if (items.isNotEmpty) {
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _descriptionController.text = items[0]["description"] ?? "";
          _dateController.text = items[0]["date"] ?? "";
          _categoryController.text = items[0]["category"] ?? "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.myCategory.bgColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyInputField(
                        title: "Title",
                        hint: "Enter title here.",
                        controller: _titleController,
                        height: 50,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: FieldAutocomplete(
                              controller: _categoryController,
                              label: "Category",
                              dbHelper: IdeasDatabaseHelper(),
                              loadItemsFunction: () async {
                                return await IdeasDatabaseHelper().getCategories(MyApp.dbPassword!);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: CupertinoDatePickerField(
                              controller: _dateController,
                              dateFormatter: _dateFormatter,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyInputField(
                        title: "Description",
                        hint: "Enter description here.",
                        controller: _descriptionController,
                        height: 200,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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


  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: widget.myCategory.bgColor,
      elevation: 0,
      title: Text(
        widget.myCategory.title ?? "Error",
        style: const TextStyle(color: Colors.black),
      ),
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}