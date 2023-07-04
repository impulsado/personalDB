import 'package:flutter/material.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/database/database_helper_common.dart';

class FieldAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final DatabaseHelperCommon dbHelper;
  final Future<List<String>> Function() loadItemsFunction;

  FieldAutocomplete({
    required this.controller,
    required this.label,
    required this.dbHelper,
    required this.loadItemsFunction,
  });

  @override
  _FieldAutocompleteState createState() => _FieldAutocompleteState();
}

class _FieldAutocompleteState extends State<FieldAutocomplete> {
  List<String> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  _loadItems() async {
    List<String> items = await widget.loadItemsFunction();

    print('Existing Items: $items');

    setState(() {
      _items = items;
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
        return _items.where((String item) {
          return item.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        widget.controller.text = selection;
      },
      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        fieldTextController.text = widget.controller.text;
        fieldTextController.selection = widget.controller.selection;
        return MyInputField(
          title: widget.label,
          hint: 'Enter ${widget.label.toLowerCase()} here.',
          controller: fieldTextController,
          height: 50,
          child: TextFormField(
            controller: fieldTextController,
            onChanged: (value) {
              widget.controller.text = value;
            },
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Enter item here.',
            ),
          ),
        );
      },
    );
  }
}
