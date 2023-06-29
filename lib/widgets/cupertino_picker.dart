import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoPickerWidget extends StatefulWidget {
  final TextEditingController controller;
  final List<String> options;

  CupertinoPickerWidget({required this.controller, required this.options});

  @override
  _CupertinoPickerWidgetState createState() => _CupertinoPickerWidgetState();
}

class _CupertinoPickerWidgetState extends State<CupertinoPickerWidget> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.options.indexOf(widget.controller.text);
    selectedIndex = selectedIndex == -1 ? 0 : selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.0,
      child: CupertinoPicker(
        itemExtent: 32.0,
        onSelectedItemChanged: (index) {
          setState(() {
            selectedIndex = index;
            widget.controller.text = widget.options[selectedIndex];
          });
        },
        children: List<Widget>.generate(widget.options.length, (index) {
          return Text(widget.options[index]);
        }),
      ),
    );
  }
}
