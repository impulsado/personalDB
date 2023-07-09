import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/widgets/star_rating.dart';
import 'package:flutter/services.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/main.dart';

class CookingDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  CookingDetailPage(this.myCategory, {this.id});

  @override
  _CookingDetailPageState createState() => _CookingDetailPageState();
}

class _CookingDetailPageState extends State<CookingDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _recipeController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  bool _isLoading = true;
  int _duration = 0;

  _submitNote(BuildContext context) async {
    if (_titleController.text.isNotEmpty &&
        _durationController.text.isNotEmpty &&
        _difficultyController.text.isNotEmpty &&
        _recipeController.text.isNotEmpty &&
        _rateController.text.isNotEmpty) {

      if(MyApp.dbPassword == null) {
        throw ArgumentError("La contraseña de la base de datos es nula");
      }

      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      final data = {
        "title": _titleController.text,
        "duration": _durationController.text,
        "difficulty": _difficultyController.text,
        "ingredients": _ingredientsController.text,
        "recipe": _recipeController.text,
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
      _rateController.clear();
      Navigator.pop(context, "refresh");
    }
  }

  _loadNote() async {
    if (widget.id != null) {
      if(MyApp.dbPassword == null) {
        throw ArgumentError("La contraseña de la base de datos es nula");
      }

      final dbHelper =
      DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!, MyApp.dbPassword!);
      if (items.isNotEmpty) {
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _durationController.text = items[0]["duration"] ?? "";
          _difficultyController.text = items[0]["difficulty"] ?? "";
          _ingredientsController.text = items[0]["ingredients"] ?? "";
          _recipeController.text = items[0]["recipe"] ?? "";
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Flexible(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Duration", style: subHeadingStyle(
                                    color: Colors.black)),
                                GestureDetector(
                                  onTap: () async {
                                    await showCupertinoModalPopup(
                                      context: context,
                                      builder: (_) =>
                                          SizedBox(
                                            height: 200,
                                            child: CupertinoTimerPicker(
                                              mode: CupertinoTimerPickerMode.hm,
                                              initialTimerDuration: Duration(
                                                  minutes: _duration),
                                              onTimerDurationChanged: (value) {
                                                HapticFeedback.selectionClick();
                                                setState(() {
                                                  _duration = value.inMinutes;
                                                  _durationController.text =
                                                  '${value.inHours}h ${value
                                                      .inMinutes.remainder(
                                                      60)}min';
                                                });
                                              },
                                            ),
                                          ),
                                    );
                                  },
                                  child: AbsorbPointer(
                                    child: CupertinoTextField(
                                      controller: _durationController,
                                      placeholder: "Duration",
                                      prefix: Icon(CupertinoIcons.time,
                                          color: CupertinoColors.inactiveGray,
                                          size: 18.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 26),
                          Flexible(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Difficulty", style: subHeadingStyle(
                                    color: Colors.black)),
                                StarRating(
                                  icon: const Icon(
                                      Icons.local_fire_department, size: 15,
                                      color: Colors.red),
                                  initialValue: _difficultyController.text
                                      .isNotEmpty ? double.parse(
                                      _difficultyController.text) : 0.0,
                                  itemSize: 30.0,
                                  onChanged: (value) {
                                    setState(() {
                                      _difficultyController.text =
                                          value.toString();
                                    });
                                  },
                                ),
                              ],
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Rate'),
                            Align(
                              alignment: Alignment.center,
                              child: StarRating(
                                initialValue: _rateController.text.isNotEmpty
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