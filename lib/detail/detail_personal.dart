import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/widgets/trust_counter.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_personal.dart';

class PersonalDetailPage extends StatefulWidget {
  final MyCategory myCategory;
  final int? id;

  PersonalDetailPage(this.myCategory, {this.id});

  @override
  _PersonalDetailPageState createState() => _PersonalDetailPageState();
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
    final dbHelper = PersonalDatabaseHelper();
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
          height: 50,
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

class _PersonalDetailPageState extends State<PersonalDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  final TextEditingController _trustController = TextEditingController();


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
      print(_typeController.text);
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(
          widget.myCategory.title ?? "Error");
      final data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "date": _dateController.text,
        "type": _typeController.text,
        "trust": _trustController.text  // Añade esta línea
      };
      print("Data to save: $data");
      if (widget.id != null) {
        await dbHelper.updateItem(widget.id!, data);
      } else {
        await dbHelper.createItem(data);
      }
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
      _typeController.clear();
      _trustController.clear();  // Añade esta línea
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
        print("Loaded item: ${items[0]}");
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
                            child: TypeAutocomplete(
                              typeController: _typeController,
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
                      const SizedBox(height: 10),
                      TrustCounter(controller: _trustController),
                      const SizedBox(height: 10),
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
        key: ValueKey('personal'),
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