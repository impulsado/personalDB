import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';

class CupertinoPickerWidget extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final List<String> options;
  final double pickerHeight;
  final bool isDurationPicker;
  final Duration? selectedDuration;
  final ValueChanged<String>? onChanged;

  const CupertinoPickerWidget({
    Key? key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.options,
    this.pickerHeight = 200.0,
    this.isDurationPicker = false,
    this.selectedDuration,
    this.onChanged,
  }) : super(key: key);

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
    return GestureDetector(
      onTap: () => _showCupertinoPicker(),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: subHeadingStyle(color: Colors.black),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 57,),
              child: Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.only(left: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    selectedIndex >= 0 ? widget.options[selectedIndex] : widget.hint,
                    style: subHeadingStyle(color: selectedIndex >= 0 ? Colors.black : Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCupertinoPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 5,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: selectedIndex >= 0 ? selectedIndex : 0),
            itemExtent: 32.0,
            onSelectedItemChanged: (index) {
              setState(() {
                selectedIndex = index;
                widget.controller.text = widget.options[selectedIndex];
                if (widget.onChanged != null) {
                  widget.onChanged!(widget.options[selectedIndex]);
                }
              });
            },
            children: List<Widget>.generate(widget.options.length, (index) {
              return Center(
                child: Text(widget.options[index]),
              );
            }),
          ),
        );
      },
    ).then((_) {
      if (selectedIndex < 0) {
        setState(() {
          selectedIndex = 0;
          widget.controller.text = widget.options[selectedIndex];
        });
      }
    });
  }
}