import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/widgets/star_rating.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/widgets/cupertino_time_picker.dart';

class CookingDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  // ignore: prefer_const_constructors_in_immutables
  CookingDetailPage(this.myCategory, {super.key, this.id});

  @override
  // ignore: library_private_types_in_public_api
  _CookingDetailPageState createState() => _CookingDetailPageState();
}

class _CookingDetailPageState extends State<CookingDetailPage> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _recipeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        initialData["duration"] != _durationController.text ||
        initialData["difficulty"] != _difficultyController.text ||
        initialData["ingredients"] != _ingredientsController.text ||
        initialData["recipe"] != _recipeController.text ||
        initialData["price"] != _priceController.text ||
        initialData["rate"] != _rateController.text;
  }

  void _updateInitialData() {
    initialData = {
      "title": _titleController.text,
      "duration": _durationController.text,
      "difficulty": _difficultyController.text,
      "ingredients": _ingredientsController.text,
      "recipe": _recipeController.text,
      "price": _priceController.text,
      "rate": _rateController.text,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _difficultyController.dispose();
    _ingredientsController.dispose();
    _recipeController.dispose();
    _priceController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  _submitNote(BuildContext context) async {

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a title")));
    } else if (_durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select the duration")));
    } else if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a price")));
    } else if (_ingredientsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the ingredients")));
    } else if (_recipeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a recipe")));
    } else if (_difficultyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please choose the difficulty")));
    } else if (_rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please choose your rate")));
    } else {
      _saveNote(context);
    }

  }

  _saveNote(BuildContext context) async {
    if (MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
    final data = {
      "title": _titleController.text,
      "duration": _durationController.text,
      "difficulty": _difficultyController.text,
      "ingredients": _ingredientsController.text,
      "recipe": _recipeController.text,
      "price": "${_priceController.text}€",
      "rate": _rateController.text,
    };

    if (widget.id != null) {
      await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
    } else {
      await dbHelper.createItem(data, MyApp.dbPassword!);
    }

    _titleController.clear();
    _durationController.clear();
    _difficultyController.clear();
    _ingredientsController.clear();
    _recipeController.clear();
    _priceController.clear();
    _rateController.clear();

    _updateInitialData();

    // ignore: use_build_context_synchronously
    Navigator.pop(context, "refresh");
  }

  _loadNote() async {
    if (widget.id != null) {
      if (MyApp.dbPassword == null) {
        throw ArgumentError("Database password is null");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);

      if (items.isNotEmpty) {
        setState(() {
          //print("Price value: ${items[0]["price"]}");
          //print("Data loaded: ${items[0]}");
          _titleController.text = items[0]["title"] ?? "";
          _durationController.text = items[0]["duration"] ?? "";
          _difficultyController.text = items[0]["difficulty"] ?? "";
          _ingredientsController.text = items[0]["ingredients"] ?? "";
          _recipeController.text = items[0]["recipe"] ?? "";
          _priceController.text = items[0]["price"] != null ? items[0]["price"].replaceAll('€', '') : "";
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyInputField(
                          title: "Title",
                          hint: "Enter title here.",
                          controller: _titleController,
                          height: 50,
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: CupertinoTimePickerWidget(
                                title: "Duration",
                                hint: "Select duration.",
                                controller: _durationController,
                              ),
                            ),
                            const SizedBox(width: 26),
                            Flexible(
                              flex: 1,
                              child: MyInputField(
                                title: "Price",
                                hint: "Enter price here.",
                                controller: _priceController,
                                inputType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),

                        MyInputField(
                          title: "Ingredients",
                          hint: "Enter ingredients here.",
                          controller: _ingredientsController,
                          height: 50,
                        ),
                        MyInputField(
                          title: "Recipe",
                          hint: "Enter recipe here.",
                          controller: _recipeController,
                          height: 150,
                          inputType: TextInputType.multiline,
                          inputAction: TextInputAction.newline,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),
                              Text("Difficulty", style: subHeadingStyle(
                                  color: Colors.black)),
                              StarRating(
                                icon: const Icon(
                                    Icons.local_fire_department, size: 15, color: Colors.red),
                                initialValue: _difficultyController.text.isNotEmpty ? double.parse(_difficultyController.text) : 0.0,
                                itemSize: 41.5,
                                onChanged: (value) {
                                  setState(() {
                                    _difficultyController.text = value.toString();
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              Text("Rate", style: subHeadingStyle(color: Colors.black)),
                              Align(
                                alignment: Alignment.center,
                                child: StarRating(
                                  initialValue: _rateController.text
                                      .isNotEmpty
                                      ? double.parse(_rateController.text)
                                      : 0.0,
                                  onChanged: (value) {
                                    setState(() {
                                      _rateController.text = value.toString();
                                    });
                                  },
                                ),
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
          if (await _onWillPop()) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}