import 'package:personaldb/constants/theme.dart';
import 'package:flutter/material.dart';

class MyPasswordField extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final TextInputType inputType;

  const MyPasswordField({
    Key? key,
    required this.title,
    required this.hint,
    required this.controller,
    this.inputType = TextInputType.text,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyPasswordFieldState createState() => _MyPasswordFieldState();
}

class _MyPasswordFieldState extends State<MyPasswordField> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top:16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: subHeadingStyle(color: Colors.black),),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 50.0,
            ),
            child: Container(
              margin: const EdgeInsets.only(top:8.0),
              padding: const EdgeInsets.only(left:14),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(12)),
              child: TextFormField(
                autofocus: false,
                cursorColor: Colors.grey,
                controller: widget.controller,
                style: subHeadingStyle(color: Colors.black),
                keyboardType: widget.inputType,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: subHeadingStyle(color: Colors.grey),
                  focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
