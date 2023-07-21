import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';

class CupertinoPickerWidget extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final List<String> options;
  final double pickerHeight;

  CupertinoPickerWidget({
    required this.title,
    required this.controller,
    required this.options,
    this.pickerHeight = 200.0,
  });

  @override
  _CupertinoPickerWidgetState createState() => _CupertinoPickerWidgetState();
}

class _CupertinoPickerWidgetState extends State<CupertinoPickerWidget> {
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.options.indexOf(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: subHeadingStyle(color: Colors.black),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 57,
            ),
            child: Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.only(left: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onTap: () => _showCupertinoPicker(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedIndex != -1 ? widget.options[selectedIndex] : "Select price.",
                    style: subHeadingStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: widget.pickerHeight,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (index) {
              setState(() {
                selectedIndex = index;
                widget.controller.text = widget.options[selectedIndex];
              });
            },
            children: List<Widget>.generate(widget.options.length, (index) {
              return Center( // Centrar el texto del picker
                child: Text(widget.options[index]),
              );
            }),
          ),
        );
      },
    );
  }
}
