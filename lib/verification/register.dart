import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:personaldb/database/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personaldb/main.dart';

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
            obscureText: true,
            controller: _passwordController,
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 0.0),),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),),
              labelText: "Password",
              labelStyle: TextStyle(color: Colors.black),
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
                if (password.isEmpty) {
                  _showErrorMessage(context, "Password cannot be empty");
                  return;
                }
                _filePath.isEmpty
                    ? await _createDatabase(context, password)
                    : await _importDatabase(context, password);
              }
                  : () async {
                await _selectDatabase(context);
              },
              child: Text(_inputPassword ? "Confirm" : "Select Database", style: const TextStyle(color: Colors.white)),
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
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showErrorMessage(context, "Error while creating database: $e");
    }
  }

  Future<void> _importDatabase(BuildContext context, String password) async {
    try {
      await DatabaseHelper.importDb(_filePath, password);
      MyApp.dbPassword = password;
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorMessage(context, 'Error while importing database: $e');
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
    final newDbFile = await File('$path/personalDB.db').create();
    return newDbFile.path;
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
