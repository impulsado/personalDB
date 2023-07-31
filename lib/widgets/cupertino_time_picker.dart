// cupertino_time_picker.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';

class CupertinoTimePickerWidget extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final String hint;

  const CupertinoTimePickerWidget({super.key,
    required this.title,
    required this.controller,
    required this.hint,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CupertinoTimePickerWidgetState createState() => _CupertinoTimePickerWidgetState();
}

class _CupertinoTimePickerWidgetState extends State<CupertinoTimePickerWidget> {
  Duration selectedDuration = Duration.zero;
  bool openedOnce = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      List<String> parts = widget.controller.text.split("h");
      if (parts.length == 2) {
        selectedDuration = Duration(
          hours: int.tryParse(parts[0].trim())!,
          minutes: int.tryParse(parts[1].replaceFirst("min", "").trim())!,
        );
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
            constraints: const BoxConstraints(minHeight: 57,),
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
                    openedOnce ? widget.controller.text : widget.hint,
                    style: subHeadingStyle(color: openedOnce ? Colors.black : Colors.grey),
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
        return SizedBox(
          height: 200,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: selectedDuration,
            onTimerDurationChanged: (Duration value) {
              selectedDuration = value;
            },
          ),
        );
      },
    ).then((_) {
      _updateText(selectedDuration);
    });
    openedOnce = true;
  }

  void _updateText(Duration duration) {
    setState(() {
      widget.controller.text = "${duration.inHours}h ${duration.inMinutes.remainder(60)}min";
    });
  }
}
