import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/widgets/cupertino_picker.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_wishlist.dart';
import 'package:personaldb/main.dart';

class WishlistDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  WishlistDetailPage(this.myCategory, {this.id});

  @override
  _WishlistDetailPageState createState() => _WishlistDetailPageState();
}

class _WishlistDetailPageState extends State<WishlistDetailPage> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late final WishlistDatabaseHelper dbHelper;

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the dbHelper
    dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error") as WishlistDatabaseHelper;

    _loadNote();
  }

  Future<bool> _onWillPop() async {
    if (_isFormModified()) {
      final confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Discard changes?"),
            content: const Text("You have unsaved changes! If you leave, you will lose these changes."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("DISCARD", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
      return confirm ?? false;
    } else {
      return true;
    }
  }

  bool _isFormModified() {
    return initialData["title"] != _titleController.text ||
        initialData["link"] != _linkController.text ||
        initialData["price"] != _priceController.text ||
        initialData["priority"] != _priorityController.text ||
        initialData["rate"] != _notesController.text;
  }

  void _updateInitialData() {
    initialData = {
      "title": _titleController.text,
      "link": _linkController.text,
      "price": _priceController.text,
      "priority": _priorityController.text,
      "notes": _notesController.text,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _priceController.dispose();
    _priorityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {
    if (_titleController.text.isNotEmpty &&
        _linkController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _priorityController.text.isNotEmpty &&
        _notesController.text.isNotEmpty) {

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

      _updateInitialData();

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

          _updateInitialData();
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                        minLines: 5,
                        inputType: TextInputType.multiline,
                        inputAction: TextInputAction.newline,
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () async {
          // If no changes were made or if user decides to discard changes, navigate back
          if (await _onWillPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
