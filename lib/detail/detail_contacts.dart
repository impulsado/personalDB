// detail_contacts.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/cupertino_picker.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_contacts.dart';
import 'package:personaldb/widgets/field_autocomplete.dart';
import 'package:personaldb/widgets/cupertino_date_picker.dart';
import 'package:personaldb/widgets/topics_list_view.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/constants/theme.dart';

class ContactsDetailPage extends StatefulWidget {
  final MyCategory? myCategory;
  final int? id;

  const ContactsDetailPage({this.myCategory, super.key, this.id});

  @override
  // ignore: library_private_types_in_public_api
  _ContactsDetailPageState createState() => _ContactsDetailPageState();
}


class _ContactsDetailPageState extends State<ContactsDetailPage> with WidgetsBindingObserver {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _remindMeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final DateFormat _birthdayFormatter = DateFormat('dd-MM-yyyy');

  late final ContactsDatabaseHelper dbHelper;

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the dbHelper
    dbHelper = DatabaseHelperFactory.getDatabaseHelper("Contacts") as ContactsDatabaseHelper;

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
    return initialData["name"] != _nameController.text ||
        initialData["birthday"] != _birthdayController.text ||
        initialData["email"] != _emailController.text ||
        initialData["phone"] != _phoneController.text ||
        initialData["label"] != _labelController.text ||
        initialData["address"] != _addressController.text ||
        initialData["remindMe"] != _remindMeController.text ||
        initialData["notes"] != _notesController.text;
  }

  void _updateInitialData() {
    initialData = {
      "name": _nameController.text,
      "birthday": _birthdayController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "label": _labelController.text,
      "address": _addressController.text,
      "remindMe": _remindMeController.text,
      "notes": _notesController.text,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _labelController.dispose();
    _addressController.dispose();
    _remindMeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the name")));
    } else if (_birthdayController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the birthday")));
    } else if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the phone number")));
    } else {
      _saveNote(context);
    }
  }

  _saveNote(BuildContext context) async {
    if(MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    final dbHelper = DatabaseHelperFactory.getDatabaseHelper("Contacts");
    final data = {
      "name": _nameController.text,
      "birthday": _birthdayController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "label": _labelController.text,
      "address": _addressController.text,
      "remindMe": _remindMeController.text,
      "notes": _notesController.text,
    };
    if (widget.id != null) {
      await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
    } else {
      await dbHelper.createItem(data, MyApp.dbPassword!);
    }
    _nameController.clear();
    _birthdayController.clear();
    _emailController.clear();
    _phoneController.clear();
    _labelController.clear();
    _addressController.clear();
    _remindMeController.clear();
    _notesController.clear();

    _updateInitialData();

    // ignore: use_build_context_synchronously
    Navigator.pop(context, "refresh");
  }

  _loadNote() async {
    if (widget.id != null) {

      if(MyApp.dbPassword == null) {
        throw ArgumentError("Database password is null");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper("Contacts");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);

      if (items.isNotEmpty) {
        setState(() {
          _nameController.text = items[0]["name"] ?? "";
          _birthdayController.text = items[0]["birthday"] ?? "";
          _emailController.text = items[0]["email"] ?? "";
          _phoneController.text = items[0]["phone"] ?? "";
          _labelController.text = items[0]["label"] ?? "";
          _addressController.text = items[0]["address"] ?? "";
          _remindMeController.text = items[0]["remindMe"] ?? "";
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
        backgroundColor: Colors.grey,
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
                        title: "Name",
                        hint: "Enter full name here.",
                        controller: _nameController,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 4,
                            child: CupertinoDatePickerField(
                              title: "Birthday",
                              hint: "Select birthday.",
                              controller: _birthdayController,
                              dateFormatter: _birthdayFormatter,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            flex: 6,
                            child: FieldAutocomplete(
                              controller: _labelController,
                              label: "Label",
                              dbHelper: ContactsDatabaseHelper(),
                              loadItemsFunction: () async {
                                return await ContactsDatabaseHelper().getLabels(MyApp.dbPassword!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 4,
                            child: MyInputField(
                              title: "Phone",
                              hint: "Enter phone.",
                              controller: _phoneController,
                              inputType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            flex: 6,
                            child: MyInputField(
                              title: "Email",
                              hint: "Enter email here.",
                              controller: _emailController,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyInputField(
                        title: "Address",
                        hint: "Enter address here.",
                        controller: _addressController,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      CupertinoPickerWidget(
                        title: "Remind Me",
                        hint: "Select when to contact again.",
                        controller: _remindMeController,
                          options: const ["1 week", "2 week", "3 weeks", "4 weeks", "5 weeks", "6 weeks", "7 weeks", "8 weeks"]
                      ),
                      const SizedBox(height: 10),
                      TopicsListView(contactId: widget.id),
                      const SizedBox(height: 10),
                      MyInputField(
                        title: "Notes",
                        hint: "Enter notes here.",
                        controller: _notesController,
                        height: 150,
                        inputType: TextInputType.multiline,
                        inputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 20),
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
          bgColor: Colors.black,
          iconColor: Colors.white,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey,
      elevation: 0,
      title: Text("Contacts", style: headingStyle(color: Colors.black)),
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
