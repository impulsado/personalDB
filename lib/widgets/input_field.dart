import 'package:personaldb/constants/theme.dart';
import 'package:flutter/material.dart';

class MyInputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  const MyInputField({Key? key,required this.title,required this.hint, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top:16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: subHeadingStyle(color: Colors.black),),
          Container(
            height: 52,
            margin: EdgeInsets.only(top:8.0),
            padding: EdgeInsets.only(left:14),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              autofocus: false,
              cursorColor: Colors.grey,
              controller: controller,
              style: subHeadingStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: subHeadingStyle(color: Colors.black),
                focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
              ),
            ),
          )
        ],
      ),
    );
  }
}