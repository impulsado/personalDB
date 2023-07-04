import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/widgets/input_field.dart';

class CupertinoDatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final DateFormat dateFormatter;

  CupertinoDatePickerField({
    required this.controller,
    required this.dateFormatter,
  });

  @override
  _CupertinoDatePickerFieldState createState() =>
      _CupertinoDatePickerFieldState();
}

class _CupertinoDatePickerFieldState extends State<CupertinoDatePickerField> {
  _selectDate(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (val) {
                    setState(() {
                      widget.controller.text =
                          widget.dateFormatter.format(val);
                    });
                  },
                  mode: CupertinoDatePickerMode.date,
                ),
              ),
              CupertinoButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: MyInputField(
          title: 'Date',
          hint: 'Select Date',
          controller: widget.controller,
        ),
      ),
    );
  }
}