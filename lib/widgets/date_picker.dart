import 'package:flutter/cupertino.dart';
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
  DateTime? selectedDate; // Variable para almacenar la fecha seleccionada

  _selectDate(BuildContext context) async {
    selectedDate = widget.controller.text.isEmpty || widget.controller.text == 'Select Date'
        ? DateTime.now()
        : widget.dateFormatter.parse(widget.controller.text);

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
                  initialDateTime: selectedDate,
                  onDateTimeChanged: (val) {
                    selectedDate = val; // Actualiza la fecha seleccionada
                  },
                  mode: CupertinoDatePickerMode.date,
                ),
              ),
              CupertinoButton(
                child: Text('OK'),
                onPressed: () {
                  // Solo actualiza el controlador si se ha seleccionado una fecha
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
          title: 'Date',
          hint: 'Select Date',
          controller: widget.controller,
        ),
      ),
    );
  }
}