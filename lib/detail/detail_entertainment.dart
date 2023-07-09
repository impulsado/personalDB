  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:personaldb/models/categories.dart';
  import 'package:personaldb/widgets/input_field.dart';
  import 'package:personaldb/widgets/button.dart';
  import 'package:personaldb/widgets/field_autocomplete.dart';
  import 'package:personaldb/database/database_helper_factory.dart';
  import 'package:personaldb/database/database_helper_entertainment.dart'; // Update this
  import 'package:personaldb/widgets/star_rating.dart';
  import 'package:personaldb/constants/theme.dart';
  import 'package:personaldb/main.dart';
  
  class EntertainmentDetailPage extends StatefulWidget {
    final MyCategory myCategory;
    final int? id;
  
    EntertainmentDetailPage(this.myCategory, {this.id});
  
    @override
    _EntertainmentDetailPageState createState() => _EntertainmentDetailPageState();
  }
  
  class _EntertainmentDetailPageState extends State<EntertainmentDetailPage> {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _authorController = TextEditingController();
    final TextEditingController _genreController = TextEditingController();
    final TextEditingController _notesController = TextEditingController();
    final TextEditingController _rateController = TextEditingController();
    late final EntertainmentDatabaseHelper dbHelper;
  
    bool _isLoading = true;
  
    _submitNote(BuildContext context) async {
      if (_titleController.text.isNotEmpty && _rateController.text.isNotEmpty) {
        
        if(MyApp.dbPassword == null) {
          throw ArgumentError("La contraseña de la base de datos es nula");
        }
        
        final dbHelper =
        DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
        final data = {
          "title": _titleController.text,
          "author": _authorController.text,
          "genre": _genreController.text,
          "notes": _notesController.text,
          "rate": _rateController.text,
        };
        if (widget.id != null) {
          await dbHelper.updateItem(widget.id!, data, MyApp.dbPassword!);
        } else {
          await dbHelper.createItem(data, MyApp.dbPassword!);
        }
        _titleController.clear();
        _authorController.clear();
        _genreController.clear();
        _notesController.clear();
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
            _authorController.text = items[0]["author"] ?? ""; // New field
            _genreController.text = items[0]["genre"] ?? ""; // New field
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
      dbHelper = EntertainmentDatabaseHelper();
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
                      FieldAutocomplete(
                        controller: _authorController,
                        label: "Author",
                        dbHelper: dbHelper,
                        loadItemsFunction: () => dbHelper.getAuthor(MyApp.dbPassword!),
                      ),
                      const SizedBox(height: 10),
                      FieldAutocomplete(
                        controller: _genreController,
                        label: "Genre",
                        dbHelper: dbHelper,
                        loadItemsFunction: () => dbHelper.getGenre(MyApp.dbPassword!),
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