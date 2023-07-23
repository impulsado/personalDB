import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/widgets/input_field.dart';

class CupertinoDatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final DateFormat dateFormatter;

  const CupertinoDatePickerField({super.key,
    required this.controller,
    required this.dateFormatter,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CupertinoDatePickerFieldState createState() =>
      _CupertinoDatePickerFieldState();
}

class _CupertinoDatePickerFieldState extends State<CupertinoDatePickerField> {
  DateTime? selectedDate;

  _selectDate(BuildContext context) async {
    selectedDate = widget.controller.text.isEmpty || widget.controller.text == "Select Date"
        ? DateTime.now()
        : widget.dateFormatter.parse(widget.controller.text);

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: selectedDate,
                  onDateTimeChanged: (val) {
                    selectedDate = val;
                  },
                  mode: CupertinoDatePickerMode.date,
                ),
              ),
              CupertinoButton(
                child: Text("OK"),
                onPressed: () {
                  if (selectedDate != null) {
                    widget.controller.text =
                        widget.dateFormatter.format(selectedDate!);
                  }
                  Navigator.of(context).pop();
                },
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
          title: "Date",
          hint: "Select date.",
          controller: widget.controller,
        ),
      ),
    );
  }
}