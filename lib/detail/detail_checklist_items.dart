import 'package:flutter/material.dart';
import 'package:personaldb/constants/colors.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/widgets/delete_button.dart';

class CheckListItemsDetailPage extends StatefulWidget {
  final int? id;
  final int checklistId;

  const CheckListItemsDetailPage({Key? key, required this.id, required this.checklistId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CheckListItemsDetailPageState createState() => _CheckListItemsDetailPageState();
}

class _CheckListItemsDetailPageState extends State<CheckListItemsDetailPage> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};
  String _checklistName = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadNote();
  }

  Future<void> _onWillPop() async {
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

      if (confirm == true) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
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

  _submitNote(BuildContext context) {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a title")));
    } else {
      _saveNote(context);
    }
  }

  _saveNote(BuildContext context) async {
    if(MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    final dbHelper = DatabaseHelperFactory.getDatabaseHelper("Check List Items");

    final data = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "checklist_id": widget.checklistId,
    };

    if (widget.id != null) {
      await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
    } else {
      await dbHelper.createItem(data, MyApp.dbPassword!);
    }
    _titleController.clear();
    _descriptionController.clear();

    _updateInitialData();

    // ignore: use_build_context_synchronously
    Navigator.pop(context, "refresh");
  }

  _loadNote() async {
    if(MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    final dbHelperChecklistsItems = DatabaseHelperFactory.getDatabaseHelper("Check List");
    List<Map<String, dynamic>> checklist = await dbHelperChecklistsItems.getItem(widget.checklistId, MyApp.dbPassword!);

    if (checklist.isNotEmpty) {
      setState(() {
        _checklistName = checklist[0]["title"];
      });
    }

    if (widget.id != null) {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper("Check List Items");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);

      if (items.isNotEmpty) {
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _descriptionController.text = items[0]["description"] ?? "";
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    _updateInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kTurquoiseLight,
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
                child: GlowingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  color: kTurquoise,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyInputField(
                            title: "Title",
                            hint: "Enter title here.",
                            controller: _titleController,
                            overflow: TextOverflow.ellipsis,
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: MyButton(
        label: "Submit",
        onTap: () => _submitNote(context),
        bgColor: kTurquoiseLight,
        iconColor: Colors.black,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kTurquoiseLight,
      elevation: 0.0,
      leading: IconButton(
        onPressed: _onWillPop,
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      title: Text(
        _checklistName,
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        DeleteButton(
          item: {"id": widget.id},
          categoryName: "Check List Items",
          onConfirmed: () {Navigator.of(context).pop("refresh");},
          dialogTitle: "Delete Item",
          dialogContent: "Are you sure you want to delete this item?",
          iconData: Icons.delete_forever_outlined,
          iconColor: Colors.black,
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}