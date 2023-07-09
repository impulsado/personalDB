import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/widgets/cupertino_picker.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:flutter/services.dart';
import 'package:personaldb/main.dart';  // Import MyApp

class WishlistDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  WishlistDetailPage(this.myCategory, {this.id});

  @override
  _WishlistDetailPageState createState() => _WishlistDetailPageState();
}

class _WishlistDetailPageState extends State<WishlistDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = true;

  _submitNote(BuildContext context) async {
    if (_titleController.text.isNotEmpty) {

      if(MyApp.dbPassword == null) {
        throw ArgumentError("La contraseña de la base de datos es nula");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      final data = {
        "title": _titleController.text,
        "link": _linkController.text,
        "price": _priceController.text + "€",
        "priority": _priorityController.text,
        "notes": _notesController.text,
      };
      if (widget.id != null) {
        await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
      } else {
        await dbHelper.createItem(data, MyApp.dbPassword!);
      }
      _titleController.clear();
      _linkController.clear();
      _priceController.clear();
      _priorityController.clear();
      _notesController.clear();
      Navigator.pop(context, "refresh");
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
          _linkController.text = items[0]["link"] ?? "";
          _priceController.text = items[0]["price"] != null ? items[0]["price"].replaceAll('€', '') : "";
          _priorityController.text = items[0]["priority"] ?? "";
          _notesController.text = items[0]["notes"] ?? "";
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
                child: ListView(
                  children: [
                    MyInputField(
                      title: "Title",
                      hint: "Enter title here.",
                      controller: _titleController,
                    ),
                    const SizedBox(height: 10),
                    MyInputField(
                      title: "Website",
                      hint: "Enter website link here.",
                      controller: _linkController,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      child: Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: MyInputField(
                              title: "Price",
                              hint: "Enter price here.",
                              controller: _priceController,
                              inputType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 15),
                          Flexible(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CupertinoPickerWidget(
                                  title: "Priority",
                                  controller: _priorityController,
                                  options: ['High', 'Medium', 'Low'],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyInputField(
                      title: "Notes",
                      hint: "Enter notes here.",
                      controller: _notesController,
                      minLines: 5, // This will make the notes field larger.
                    ),
                  ],
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
