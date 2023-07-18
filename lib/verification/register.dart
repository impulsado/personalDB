import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:personaldb/database/database_helper.dart';
import 'package:path_provider/path_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _creatingDatabase = false;
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
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/icon.jpg', height: 250.0, width: 250.0),
          SizedBox(height: 30.0),
          _creatingDatabase
              ? TextField(
            obscureText: true,
            controller: _passwordController,
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 0.0),),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),),
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.black),
            ),
          )
              : Container(
            width: double.infinity,
            height: 50.0,
            margin: EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _creatingDatabase = true;
                });
              },
              child: const Text('Create New Database', style: TextStyle(color: Colors.white)),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50.0,
            margin: EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: _creatingDatabase
                  ? () async {
                final password = _passwordController.text;
                if (password.isEmpty) {
                  _showErrorMessage(context, 'Password cannot be empty');
                  return;
                }
                await _createDatabase(context, password);
              }
                  : () => _importDatabase(context),
              child: Text(_creatingDatabase ? 'Create' : 'Import Database', style: TextStyle(color: Colors.white)),
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
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _showErrorMessage(context, 'Error while creating database: $e');
    }
  }

  void _importDatabase(BuildContext context) async {
    final newPath = await _askImportDatabase(context);
    if (newPath == null) {
      return;
    }

    final password = await DatabaseHelper.askPassword(context);
    if (password == null || password.isEmpty) {
      _showErrorMessage(context, 'Action cancelled or empty password');
      return;
    }

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appStoragePath = appDocDir.path;

      // Create a new file in the app storage with the same name as the imported file
      File importedDbFile = File(newPath);
      String newDbPath = '$appStoragePath/${importedDbFile.path.split('/').last}';
      await importedDbFile.copy(newDbPath);

      // Update the db path in DatabaseHelper to the new location
      DatabaseHelper.dbPath = newDbPath;

      await DatabaseHelper.db(password);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _showErrorMessage(context, 'Incorrect password or error while importing database: $e');
    }
  }

  Future<String?> _askCreateDatabase(BuildContext context) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;
    final newDbFile = await File('$path/personalDB.db').create();
    return newDbFile.path;
  }

  Future<String?> _askImportDatabase(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      return result.files.single.path;
    }
    return null;
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

