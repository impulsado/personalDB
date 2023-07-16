import 'package:personaldb/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyInputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final int minLines;
  final Widget? child;
  final double? height;
  final TextInputType inputType;
  final TextInputAction? inputAction;

  const MyInputField({
    Key? key,
    required this.title,
    required this.hint,
    required this.controller,
    this.minLines = 1,
    this.child,
    this.height,
    this.inputType = TextInputType.text,
    this.inputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top:16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: subHeadingStyle(color: Colors.black),),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height ?? 50.0,
            ),
            child: Container(
              margin: const EdgeInsets.only(top:8.0),
              padding: const EdgeInsets.only(left:14),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(12)),
              child: child ?? TextFormField(
                autofocus: false,
                cursorColor: Colors.grey,
                controller: controller,
                style: subHeadingStyle(color: Colors.black),
                keyboardType: inputType,
                minLines: minLines,
                maxLines: null,
                textInputAction: inputAction,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: subHeadingStyle(color: Colors.black),
                  focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
