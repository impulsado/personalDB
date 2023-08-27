import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_inventory.dart';
import 'package:personaldb/widgets/field_autocomplete.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/widgets/photo_uploader.dart';

class InventoryDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  const InventoryDetailPage(this.myCategory, {super.key, this.id});

  @override
  // ignore: library_private_types_in_public_api
  _InventoryDetailPageState createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> with WidgetsBindingObserver {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _asset1Controller = TextEditingController();
  final TextEditingController _asset2Controller = TextEditingController();
  String selectedLocation = "";
  late final InventoryDatabaseHelper dbHelper;
  late PhotoUploader _photoUploader;

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _photoUploader = PhotoUploader(controller1: _asset1Controller, controller2: _asset2Controller, appBarBackgroundColor: widget.myCategory.bgColor);

    // Initialize the dbHelper
    dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error") as InventoryDatabaseHelper;

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
    return initialData["item"] != _itemController.text ||
        initialData["quantity"] != _quantityController.text ||
        initialData["price"] != _priceController.text ||
        initialData["location"] != selectedLocation ||
        initialData["asset1"] != _asset1Controller.text ||
        initialData["asset2"] != _asset2Controller.text ||
        initialData["notes"] != _notesController.text;
  }

  void _updateInitialData() {
    initialData = {
      "item": _itemController.text,
      "quantity": _quantityController.text,
      "price": _priceController.text,
      "location": selectedLocation,
      "asset1": _asset1Controller.text,
      "asset2": _asset2Controller.text,
      "notes": _notesController.text,
    };
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _asset1Controller.dispose();
    _asset2Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {
    if (_itemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the item name")));
    } else if (selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a location")));
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
      "item": _itemController.text,
      "quantity": _quantityController.text,
      "price": "${_priceController.text}€",
      "location": selectedLocation,
      "asset1": _asset1Controller.text,
      "asset2": _asset2Controller.text,
      "notes": _notesController.text,
    };
    if (widget.id != null) {
      await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
    } else {
      await dbHelper.createItem(data, MyApp.dbPassword!);
    }
    _itemController.clear();
    _quantityController.clear();
    _priceController.clear();
    _asset1Controller.clear();
    _asset2Controller.clear();
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

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);

      if (items.isNotEmpty) {
        setState(() {
          _itemController.text = items[0]["item"] ?? "";
          _quantityController.text = items[0]["quantity"] ?? "";
          _priceController.text = items[0]["price"] != null ? items[0]["price"].replaceAll('€', '') : "";
          selectedLocation = items[0]["location"] ?? "";
          _asset1Controller.text = items[0]["asset1"] ?? "";
          _asset2Controller.text = items[0]["asset2"] ?? "";
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
                    color: Colors.orange,
                    child: ListView(
                      children: [
                        MyInputField(
                          title: "Item",
                          hint: "Enter item here.",
                          controller: _itemController,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        FieldAutocomplete(
                          label: "Location",
                          initialValue: selectedLocation,
                          onSelected: (String value) {
                            setState(() {
                              selectedLocation = value;
                            });
                          },
                          loadItemsFunction: () async {
                            return await InventoryDatabaseHelper().getLocations(MyApp.dbPassword!);
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                              flex: 5,
                              child: MyInputField(
                                title: "Quantity",
                                hint: "Enter quantity here.",
                                controller: _quantityController,
                                inputType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              flex: 5,
                              child: MyInputField(
                                title: "Price",
                                hint: "Enter price here.",
                                controller: _priceController,
                                inputType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _photoUploader,
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