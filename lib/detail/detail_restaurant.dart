import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/widgets/cupertino_picker.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_restaurant.dart';
import 'package:personaldb/widgets/star_rating.dart';
import 'package:flutter/services.dart';
import 'package:personaldb/constants/theme.dart';

class RestaurantDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  RestaurantDetailPage(this.myCategory, {this.id});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class TypeAutocomplete extends StatefulWidget {
  final TextEditingController typeController;

  TypeAutocomplete({required this.typeController});

  @override
  _TypeAutocompleteState createState() => _TypeAutocompleteState();
}

class _TypeAutocompleteState extends State<TypeAutocomplete> {
  List<String> _types = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  _loadTypes() async {
    final dbHelper = RestaurantDatabaseHelper();
    List<String> items = await dbHelper.getTypes();

    print('Existing Types: $items');

    setState(() {
      _types = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _types.where((String type) {
          return type
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        widget.typeController.text = selection;
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        fieldTextController.text = widget.typeController.text;
        fieldTextController.selection = widget.typeController.selection;
        return MyInputField(
          title: 'Type',
          hint: 'Enter type here.',
          controller: fieldTextController,
          child: TextFormField(
            controller: fieldTextController,
            onChanged: (value) {
              widget.typeController.text = value;
            },
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Enter type here.',
            ),
          ),
        );
      },
    );
  }
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  bool _isLoading = true;

  _submitNote(BuildContext context) async {
    if (_titleController.text.isNotEmpty && _rateController.text.isNotEmpty) {
      final dbHelper =
      DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      final data = {
        "title": _titleController.text,
        "location": _locationController.text,
        "type": _typeController.text,
        "price": _priceController.text,
        "notes": _notesController.text,
        "rate": _rateController.text,
      };
      if (widget.id != null) {
        await dbHelper.updateItem(widget.id!, data);
      } else {
        await dbHelper.createItem(data);
      }
      _titleController.clear();
      _locationController.clear();
      _typeController.clear();
      _priceController.clear();
      _notesController.clear();
      _rateController.clear();
      Navigator.pop(context, "refresh");
    }
  }

  _loadNote() async {
    if (widget.id != null) {
      final dbHelper =
      DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!);
      if (items.isNotEmpty) {
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _locationController.text = items[0]["location"] ?? "";
          _typeController.text = items[0]["type"] ?? "";
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
                      title: "Location",
                      hint: "Enter Google Maps link here.",
                      controller: _locationController,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      child: Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: TypeAutocomplete(
                              typeController: _typeController,
                            ),
                          ),
                          SizedBox(width: 15),
                          Flexible(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CupertinoPickerWidget(
                                  title: "Price",
                                  controller: _priceController,
                                  options: ['0€ - 10€', '10€ - 15€', '15€ - 20€', '+ 20€'],
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
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rate', style: subHeadingStyle(color: Colors.black)),
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
