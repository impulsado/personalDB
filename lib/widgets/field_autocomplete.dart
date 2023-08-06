import 'package:flutter/material.dart';
import 'package:personaldb/widgets/input_field.dart';
import 'package:personaldb/database/database_helper_common.dart';
import 'package:personaldb/constants/theme.dart';

class FieldAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final DatabaseHelperCommon dbHelper;
  final Future<List<String>> Function() loadItemsFunction;
  final double widthMultiplier;

  const FieldAutocomplete({
    super.key,
    required this.controller,
    required this.label,
    required this.dbHelper,
    required this.loadItemsFunction,
    this.widthMultiplier = 0.5,
  });

  @override
  // ignore: library_private_types_in_public_api
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

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == "") {
          return _items;
        }
        return _items.where((String item) {
          return item.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        widget.controller.text = selection;
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * widget.widthMultiplier,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        fieldTextController.text = widget.controller.text;
        fieldTextController.selection = widget.controller.selection;
        return MyInputField(
          title: widget.label,
          hint: "Enter ${widget.label.toLowerCase()} here.",
          controller: fieldTextController,
          height: 50,
          child: TextFormField(
            cursorColor: Colors.grey,
            controller: fieldTextController,
            onChanged: (value) {
              widget.controller.text = value;
            },
            onTap: () {
              if (fieldTextController.text == "") {
                fieldTextController.text = ""; // Trigger Autocomplete to show all options.
              }
            },
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: "Enter ${widget.label.toLowerCase()} here.",
              hintStyle: subHeadingStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        );
      },
    );
  }
}
