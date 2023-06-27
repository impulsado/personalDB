import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_ideas.dart';

class IdeasDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  IdeasDetailPage(this.myCategory, {this.id});

  @override
  _IdeasDetailPageState createState() => _IdeasDetailPageState();
}

class CategoryAutocomplete extends StatefulWidget {
  final TextEditingController categoryController;

  CategoryAutocomplete({required this.categoryController});

  @override
  _CategoryAutocompleteState createState() => _CategoryAutocompleteState();
}

class _CategoryAutocompleteState extends State<CategoryAutocomplete> {
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _loadCategories() async {
    final dbHelper = IdeasDatabaseHelper();
    List<String> items = await dbHelper.getCategories();

    // Imprimir categorías existentes
    print('Existing Categories: $items');

    setState(() {
      _categories = items;
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
        return _categories.where((String category) {
          return category
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        widget.categoryController.text = selection;
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return MyInputField(
          title: 'Category',
          hint: 'Enter category here.',
          controller: widget.categoryController,
          height: 50,
          child: TextFormField(
            controller: fieldTextController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Enter category here.',
            ),
          ),
        );
      },
    );
  }
}

class _IdeasDetailPageState extends State<IdeasDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  bool _isLoading = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = _dateFormatter.format(picked);
      });
    }
  }

  _submitNote(BuildContext context) async {
    print("submit");
    if (_titleController.text.isNotEmpty) {
      print(_categoryController.text);
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(
          widget.myCategory.title ?? "Error");
      final data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "date": _dateController.text,
        "category": _categoryController.text
      };
      print("Data to save: $data");  // Añade esta línea
      if (widget.id != null) {
        await dbHelper.updateItem(widget.id!, data);
      } else {
        await dbHelper.createItem(data);
      }
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
      _categoryController.clear();
      Navigator.pop(context, "refresh");
    } else {
      print("No entro");
    }
  }

  _loadNote() async {
    if (widget.id != null) {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(
          widget.myCategory.title ?? "Error");
      List<Map<String, dynamic>> items = await dbHelper.getItem(widget.id!);
      if (items.isNotEmpty) {
        print("Loaded item: ${items[0]}");  // Añade esta línea
        setState(() {
          _titleController.text = items[0]["title"] ?? "";
          _descriptionController.text = items[0]["description"] ?? "";
          _dateController.text = items[0]["date"] ?? "";
          _categoryController.text = items[0]["category"] ?? "";
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

  @override
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
                          height: 50),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: CategoryAutocomplete(
                              categoryController: _categoryController,
                            ),
                          ),
                          const SizedBox(width: 10),  // Añade espacio entre los dos campos
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: MyInputField(
                                  title: 'Date',
                                  hint: 'Select Date',
                                  controller: _dateController,
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyInputField(
                          title: "Description",
                          hint: "Enter description here.",
                          controller: _descriptionController,
                          height: 200
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
        iconColor: Colors.black,
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