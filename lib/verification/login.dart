import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/main.dart';
import 'package:path_provider/path_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final storage = new FlutterSecureStorage();
  final _passwordController = TextEditingController();
  late Future<bool> dbExists;

  @override
  void initState() {
    super.initState();
    dbExists = _checkIfDatabaseExistsAndInitialized();
  }

  Future<bool> _checkIfDatabaseExistsAndInitialized() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = docDirectory.listSync();

    for (FileSystemEntity file in files) {
      if (file.path.endsWith('.db')) {
        DatabaseHelper.dbPath = file.path;
        return true;
      }
    }

    await storage.delete(key: 'db_path');
    await storage.delete(key: 'db_password');

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: dbExists,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                //title: Text('', style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
              body: SingleChildScrollView(child: _loginForm()),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/register');
            });
            return const SizedBox.shrink();
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _loginForm() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/icon.jpg', height: 250.0, width: 250.0),
          const SizedBox(height: 30.0),
          TextField(
            cursorColor: Colors.black,
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () => _login(context),
            child: const Text('Log In', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20.0),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
            child: const Text('Create/Import Database', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _login(BuildContext context) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      _showErrorMessage(context, 'Empty password');
      return;
    }

    if (DatabaseHelper.dbPath != null) {
      bool passwordCorrect = await DatabaseHelper.validatePassword(DatabaseHelper.dbPath!, password);
      if (!passwordCorrect) {
        _showErrorMessage(context, 'Incorrect password');
        return;
      }
    } else {
      _showErrorMessage(context, 'Database path not found');
      return;
    }

    await DatabaseHelper.db(password);
    MyApp.dbPassword = password;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
