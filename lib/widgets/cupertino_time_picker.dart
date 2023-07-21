import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';

class CupertinoTimePickerWidget extends StatefulWidget {
  final String title;
  final TextEditingController controller;

  CupertinoTimePickerWidget({
    required this.title,
    required this.controller,
  });

  @override
  _CupertinoTimePickerWidgetState createState() => _CupertinoTimePickerWidgetState();
}

class _CupertinoTimePickerWidgetState extends State<CupertinoTimePickerWidget> {
  int durationMinutes = 0;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      List<String> parts = widget.controller.text.split('h');
      if (parts.length == 2) {
        durationMinutes = int.tryParse(parts[0].trim())! * 60 + int.tryParse(parts[1].replaceFirst('min', '').trim())!;
      }
    }
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
                onTap: () => _showCupertinoTimePicker(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.controller.text.isNotEmpty ? widget.controller.text : "Select duration.",
                    style: subHeadingStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 200,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: Duration(minutes: durationMinutes),
            onTimerDurationChanged: (Duration value) {
              setState(() {
                durationMinutes = value.inMinutes;
                widget.controller.text = '${value.inHours}h ${value.inMinutes.remainder(60)}min';
              });
            },
          ),
        );
      },
    );
  }
}
