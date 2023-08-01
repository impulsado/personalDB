import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:personaldb/database/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/widgets/notifications_handler.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _inputPassword = false;
  String _filePath = "";
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: _registerForm(),
      ),
    );
  }

  Widget _registerForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/icon.jpg", height: 250.0, width: 250.0),
          const SizedBox(height: 30.0),
          _inputPassword
              ? TextField(
            obscureText: _obscureText,
            controller: _passwordController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 0.0),),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),),
              labelText: "Password",
              labelStyle: const TextStyle(color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          )
              : Container(
            width: double.infinity,
            height: 50.0,
            margin: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _inputPassword = true;
                });
              },
              child: const Text("Create New Database", style: TextStyle(color: Colors.white)),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50.0,
            margin: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: _inputPassword
                  ? () async {
                final password = _passwordController.text;
                final passwordValidation = validatePassword(password);
                if (passwordValidation != null) {
                  _showErrorMessage(context, passwordValidation);
                  return;
                }
                _filePath.isEmpty
                    ? await _createDatabase(context, password)
                    : await _importDatabase(context, password);
              }
                  : () async {
                await _selectDatabase(context);
              },
              child: Text(_inputPassword ? "Confirm" : "Import Existing Database", style: const TextStyle(color: Colors.white)),
            ),
          ),

        ],
      ),
    );
  }

  Future<void> _createDatabase(BuildContext context, String password) async {
    final newPath = await _askCreateDatabase(context);
    if (newPath == null) {
      return;
    }

    try {
      await DatabaseHelper.createDb(newPath, password);
      MyApp.dbPassword = password;
      NotificationHandler.testNotification();
      NotificationHandler.privacyNotification();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showErrorMessage(context, "Error while creating database: $e");
    }
  }

  Future<void> _importDatabase(BuildContext context, String password) async {
    try {
      await DatabaseHelper.importDb(_filePath, password);
      MyApp.dbPassword = password;
      NotificationHandler.testNotification();
      NotificationHandler.privacyNotification();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      _showErrorMessage(context, "Error while importing database: $e");
    }
  }

  Future<void> _selectDatabase(BuildContext context) async {
    final newFilePath = await FilePicker.platform.pickFiles(type: FileType.any);
    if (newFilePath != null && newFilePath.files.single.path != null) {
      _filePath = newFilePath.files.single.path!;
      setState(() {
        _inputPassword = true;
      });
    }
  }

  Future<String?> _askCreateDatabase(BuildContext context) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;
    final newDbFile = await File("$path/personalDB.db").create();
    return newDbFile.path;
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? validatePassword(String password) {
    if (password.length < 8) return "Password must be at least 8 characters long";

    if (!RegExp(r"[a-z]").hasMatch(password)) return "Password must contain at least one lower case letter";

    if (!RegExp(r"[A-Z]").hasMatch(password)) return "Password must contain at least one upper case letter";

    if (!RegExp(r"\d").hasMatch(password)) return "Password must contain at least one number";

    var specialChars = ["@", "\$", "!", "%", "*", "?", "&", "#", "-", "_", "+", "=", "~", "^", "[", "]", "{", "}", "|", "\\", ":", ";", ",", ".", "<", ">", "/", "(", ")"];
    if (!specialChars.any((char) => password.contains(char))) return "Password must contain at least one special character";

    return null;
  }
}
