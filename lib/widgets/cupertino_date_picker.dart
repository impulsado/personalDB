import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:personaldb/widgets/input_field.dart';

class CupertinoDatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final DateFormat dateFormatter;
  final String title;
  final String hint;

  const CupertinoDatePickerField({
    Key? key,
    required this.controller,
    required this.dateFormatter,
    this.title = "Date",
    this.hint = "Select date.",
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CupertinoDatePickerFieldState createState() => _CupertinoDatePickerFieldState();
}

class _CupertinoDatePickerFieldState extends State<CupertinoDatePickerField> {
  DateTime? selectedDate;

  _selectDate(BuildContext context) async {
    selectedDate = widget.controller.text.isEmpty || widget.controller.text == widget.hint
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
                child: const Text("OK"),
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
          title: widget.title,
          hint: widget.hint,
          controller: widget.controller,
        ),
      ),
    );
  }
}
