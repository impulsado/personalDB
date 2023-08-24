import 'package:flutter/material.dart';
import 'package:personaldb/constants/colors.dart';
import 'package:personaldb/database/database_helper_checklists.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/widgets/checklist_items.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/main.dart';

class CheckListDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  // ignore: prefer_const_constructors_in_immutables
  CheckListDetailPage(this.myCategory, {super.key, this.id});

  @override
  // ignore: library_private_types_in_public_api
  _CheckListDetailPageState createState() => _CheckListDetailPageState();
}

class _CheckListDetailPageState extends State<CheckListDetailPage> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late int checklistId;
  late final CheckListDatabaseHelper dbHelper;


  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    dbHelper = DatabaseHelperFactory.getDatabaseHelper("Check List") as CheckListDatabaseHelper;

    checklistId = widget.id ?? 0;
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
        initialData["notes"] != _notesController.text;
  }

  void _updateInitialData() {
    initialData = {
      "title": _titleController.text,
      "notes": _notesController.text,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a title")));
    } else {
      _saveNote(context);
    }
  }

  _saveNote(BuildContext context) async {
    if (MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    final dbHelper = DatabaseHelperFactory.getDatabaseHelper("Check List");
    final data = {
      "title": _titleController.text,
      "notes": _notesController.text,
    };

    if (widget.id != null) {
      await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
    } else {
      await dbHelper.createItem(data, MyApp.dbPassword!);
    }

    _titleController.clear();
    _notesController.clear();

    _updateInitialData();

    // ignore: use_build_context_synchronously
    Navigator.pop(context, "refresh");
  }

  _loadNote() async {
    if (widget.id != null) {
      if (MyApp.dbPassword == null) {
        throw ArgumentError("Database password is null");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper("Check List");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);

      if (items.isNotEmpty) {
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _notesController.text = items[0]["notes"] ?? "";
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: widget.myCategory.bgColor ?? Colors.yellow,
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
                            height: 50,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          CheckListWidget(checkListId: checklistId, password: MyApp.dbPassword!),
                          const SizedBox(height: 10),
                          MyInputField(
                            title: "Notes",
                            hint: "Enter notes here.",
                            controller: _notesController,
                            height: 150,
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
          bgColor: widget.myCategory.bgColor ?? Colors.white,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: widget.myCategory.bgColor ?? Colors.red,
      elevation: 0,
      title: Text(widget.myCategory.title ?? "Error", style: headingStyle(color: Colors.black)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () async {
          if (await _onWillPop()) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}