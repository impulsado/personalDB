// detail_contacts.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/constants/colors.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/cupertino_picker.dart';
import 'package:personaldb/widgets/location_picker.dart';
import 'package:personaldb/widgets/maintance_checker.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_vehicles.dart';
import 'package:personaldb/widgets/cupertino_date_picker.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/constants/theme.dart';

class VehiclesDetailPage extends StatefulWidget {
  final MyCategory? myCategory;
  final int? id;

  const VehiclesDetailPage({this.myCategory, super.key, this.id});

  @override
  // ignore: library_private_types_in_public_api
  _VehiclesDetailPageState createState() => _VehiclesDetailPageState();
}


class _VehiclesDetailPageState extends State<VehiclesDetailPage> with WidgetsBindingObserver {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _nextMaintanceController = TextEditingController();
  final TextEditingController _remindMeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final DateFormat _maintanceFormatter = DateFormat("dd-MM-yyyy");
  late final VehiclesDatabaseHelper dbHelper;

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the dbHelper
    dbHelper = DatabaseHelperFactory.getDatabaseHelper("Vehicles") as VehiclesDatabaseHelper;

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
        initialData["registration"] != _registrationController.text ||
        initialData["next_maintenance"] != _nextMaintanceController.text ||
        initialData["remindMe"] != _remindMeController.text ||
        initialData["location"] != _locationController.text ||
        initialData["notes"] != _notesController.text;
  }

  void _updateInitialData() {
    initialData = {
      "name": _nameController.text,
      "registration": _registrationController.text,
      "next_maintenance": _nextMaintanceController.text,
      "remindMe": _remindMeController.text,
      "location": _locationController.text,
      "notes": _notesController.text,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    _nextMaintanceController.dispose();
    _remindMeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the name")));
    } else {
      _saveNote(context);
    }
  }

  _saveNote(BuildContext context) async {
    if(MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    final dbHelper = DatabaseHelperFactory.getDatabaseHelper("Vehicles");
    final data = {
      "name": _nameController.text,
      "registration": _registrationController.text,
      "next_maintenance": _nextMaintanceController.text,
      "remindMe": _remindMeController.text,
      "location": _locationController.text,
      "notes": _notesController.text,
    };

    if (widget.id != null) {
      await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
    } else {
      await dbHelper.createItem(data, MyApp.dbPassword!);
    }

    if (_remindMeController.text != "Do not remind me") {
      await MaintanceNotifications.scheduleNotification(
        _nameController.text,
        _remindMeController.text,
      );
    }

    _nameController.clear();
    _registrationController.clear();
    _nextMaintanceController.clear();
    _remindMeController.clear();
    _locationController.clear();
    _notesController.clear();

    _updateInitialData();

    // ignore: use_build_context_synchronously
    Navigator.pop(context, "refresh");
  }


  DateTime parseMaintance(String date) {
    List<String> parts = date.split('-');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  _loadNote() async {
    if (widget.id != null) {
      if(MyApp.dbPassword == null) {
        throw ArgumentError("Database password is null");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper("Vehicles");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);

      if (items.isNotEmpty) {
        setState(() {
          _nameController.text = items[0]["name"] ?? "";
          _registrationController.text = items[0]["registration"] ?? "";
          _nextMaintanceController.text = items[0]["next_maintance"] ?? "";
          _remindMeController.text = items[0]["remindMe"] ?? "";
          _locationController.text = items[0]["location"] ?? "";
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
        backgroundColor: kMetalLight,
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
                      MyInputField(
                        title: "Registration",
                        hint: "Enter registration here.",
                        controller: _registrationController,
                        overflow: TextOverflow.ellipsis,
                      ),
                      //const SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: CupertinoDatePickerField(
                              title: "Next Maintance",
                              hint: "Select next maintance.",
                              controller: _nextMaintanceController,
                              dateFormatter: _maintanceFormatter,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            flex: 5,
                            child: CupertinoPickerWidget(
                                title: "Remind Me",
                                hint: "Remember me in",
                                controller: _remindMeController,
                                options: const ["Do not remind me", "1 day before", "1 week before", "2 weeks before", "1 month before", "2 months before",]
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LocationPicker(
                        initialCoordinates: _locationController.text,
                        onLocationPicked: (coordinates) {
                          _locationController.text = coordinates;
                        },
                      ),
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
      backgroundColor: kMetalLight,
      elevation: 0,
      title: Text("Vehicles", style: headingStyle(color: Colors.black)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () async {
          // If no changes were made or if user decides to discard changes, navigate back
          if (await _onWillPop()) {
            // ignore: use_build_context_synchronously
            Navigator.of(context,).pop();
          }
        },
      ),
    );
  }
}