import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_others.dart';
import 'package:personaldb/main.dart';

class OthersDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  OthersDetailPage(this.myCategory, {this.id});

  @override
  _OthersDetailPageState createState() => _OthersDetailPageState();
}

class _OthersDetailPageState extends State<OthersDetailPage> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final OthersDatabaseHelper dbHelper;

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the dbHelper
    dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error") as OthersDatabaseHelper;

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
        initialData["description"] != _descriptionController.text;
  }

  void _updateInitialData() {
    initialData = {
      "title": _titleController.text,
      "description": _descriptionController.text,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {

      if(MyApp.dbPassword == null) {
        throw ArgumentError("La contraseña de la base de datos es nula");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      final data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
      };
      if (widget.id != null) {
        await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
      } else {
        await dbHelper.createItem(data, MyApp.dbPassword!);
      }
      _titleController.clear();
      _descriptionController.clear();

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
          _descriptionController.text = items[0]["description"] ?? "";
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

  @override
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyInputField(
                            title: "Title",
                            hint: "Enter title here.",
                            controller: _titleController,
                            height: 50),
                        const SizedBox(height: 10),
                        MyInputField(
                            title: "Description",
                            hint: "Enter description here.",
                            controller: _descriptionController,
                            height: 200,
                            inputType: TextInputType.multiline,
                            inputAction: TextInputAction.newline,
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
          iconColor: Colors.black,
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