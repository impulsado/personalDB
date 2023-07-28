import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/widgets/trust_counter.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_personal.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/widgets/field_autocomplete.dart';
import 'package:personaldb/widgets/date_picker.dart';
import 'package:personaldb/main.dart';

class PersonalDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  // ignore: prefer_const_constructors_in_immutables
  PersonalDetailPage(this.myCategory, {super.key, this.id});

  @override
  // ignore: library_private_types_in_public_api
  _PersonalDetailPageState createState() => _PersonalDetailPageState();
}

class _PersonalDetailPageState extends State<PersonalDetailPage> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _trustController = TextEditingController();
  late final PersonalDatabaseHelper dbHelper;

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the dbHelper
    dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error") as PersonalDatabaseHelper;

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
        initialData["description"] != _descriptionController.text ||
        initialData["date"] != _dateController.text ||
        initialData["type"] != _typeController.text ||
        initialData["trust"] != _trustController.text;
  }

  void _updateInitialData() {
    initialData = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "date": _dateController.text,
      "type": _typeController.text,
      "trust": _trustController.text,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    //_dateFormatter.dispose();
    _typeController.dispose();
    _trustController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a title")));
    } else if (_typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a type")));
    } else if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a description")));
    } else {
      _saveNote(context);
    }
  }

  _saveNote(BuildContext context) async {
    if(MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
    DateTime date = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    String formattedDate = _dateFormatter.format(date);
    final data = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "date": formattedDate,
      "type": _typeController.text,
      "trust": _trustController.text
    };
    if (widget.id != null) {
      await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
    } else {
      await dbHelper.createItem(data, MyApp.dbPassword!);
    }
    _titleController.clear();
    _descriptionController.clear();
    _dateController.clear();
    _typeController.clear();
    _trustController.clear();

    _updateInitialData();

    // ignore: use_build_context_synchronously
    Navigator.pop(context, "refresh");
  }

  _loadNote() async {
    if (widget.id != null) {
      if(MyApp.dbPassword == null) {
        throw ArgumentError("Database password is null");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);
      if (items.isNotEmpty) {
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _descriptionController.text = items[0]["description"] ?? "";
          _dateController.text = items[0]["date"] ?? "";
          _typeController.text = items[0]["type"] ?? "";
          _trustController.text = items[0]["trust"] ?? "";
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
                          overflow: TextOverflow.ellipsis,),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: FieldAutocomplete(
                                controller: _typeController,
                                label: "Type",
                                dbHelper: PersonalDatabaseHelper(),
                                loadItemsFunction: () async {
                                  return await PersonalDatabaseHelper().getTypes(MyApp.dbPassword!);
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
                            inputType: TextInputType.multiline,
                            inputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 27),
                        Text("Trust", style: subHeadingStyle(color: Colors.black)),
                        const SizedBox(height: 5),
                        Center(
                          child: TrustCounter(controller: _trustController),
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
          key: const ValueKey("personal"),
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
      title: Text(widget.myCategory.title ?? "Error", style: headingStyle(color: Colors.black)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () async {
          // If no changes were made or if user decides to discard changes, navigate back
          if (await _onWillPop()) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}