import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/widgets/cupertino_picker.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_restaurant.dart';
import 'package:personaldb/widgets/star_rating.dart';
import 'package:personaldb/widgets/field_autocomplete.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/main.dart';

class RestaurantDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  const RestaurantDetailPage(this.myCategory, {super.key, this.id});

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}


class _RestaurantDetailPageState extends State<RestaurantDetailPage> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  String selectedType = "";
  late final RestaurantDatabaseHelper dbHelper;

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the dbHelper
    dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error") as RestaurantDatabaseHelper;

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
        initialData["location"] != _locationController.text ||
        initialData["type"] != selectedType ||
        initialData["price"] != _priceController.text ||
        initialData["notes"] != _notesController.text ||
        initialData["rate"] != _rateController.text;
  }

  void _updateInitialData() {
    initialData = {
      "title": _titleController.text,
      "location": _locationController.text,
      "type": selectedType,
      "price": _priceController.text,
      "notes": _notesController.text,
      "rate": _rateController.text,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a title")));
    } else if (_notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your notes")));
    } else if (_rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please choose your rate")));
    } else {
      _saveNote(context);
    }
  }

  _saveNote(BuildContext context) async {
    if(MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
    final data = {
      "title": _titleController.text,
      "location": _locationController.text,
      "type": selectedType,
      "price": _priceController.text,
      "notes": _notesController.text,
      "rate": _rateController.text,
    };
    if (widget.id != null) {
      await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
    } else {
      await dbHelper.createItem(data, MyApp.dbPassword!);
    }
    _titleController.clear();
    _locationController.clear();
    _priceController.clear();
    _notesController.clear();
    _rateController.clear();

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
          _locationController.text = items[0]["location"] ?? "";
          selectedType = items[0]["type"] ?? "";
          _priceController.text = items[0]["price"] ?? "";
          _notesController.text = items[0]["notes"] ?? "";
          _rateController.text = items[0]["rate"] ?? "";
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
                  child: GlowingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    color: Colors.blue,
                    child: ListView(
                      children: [
                        MyInputField(
                          title: "Title",
                          hint: "Enter title here.",
                          controller: _titleController,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        MyInputField(
                          title: "Location",
                          hint: "Enter Google Maps link here.",
                          controller: _locationController,
                          overflow: TextOverflow.ellipsis,
                          isLink: true,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                              flex: 5,
                              child: FieldAutocomplete(
                                label: "Type",
                                initialValue: selectedType,
                                onSelected: (String value) {
                                  setState(() {
                                    selectedType = value;
                                  });
                                },
                                loadItemsFunction: () async {
                                  return await RestaurantDatabaseHelper().getTypes(MyApp.dbPassword!);
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CupertinoPickerWidget(
                                    title: "Price",
                                    hint: "Select price.",
                                    controller: _priceController,
                                    options: const ["0€ - 10€", "10€ - 15€", "15€ - 20€", "+ 20€"],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Rate", style: subHeadingStyle(color: Colors.black)),
                              StarRating(
                                initialValue: _rateController.text.isNotEmpty ? double.parse(_rateController.text) : 0.0,
                                onChanged: (value) {
                                  setState(() {
                                    _rateController.text = value.toString();
                                  });
                                },
                              ),
                            ],
                          ),
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
          bgColor: widget.myCategory.bgColor ?? Colors.white,
          iconColor: Colors.black,
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
