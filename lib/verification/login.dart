import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personaldb/detail/detail_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final storage = const FlutterSecureStorage();
  final _passwordController = TextEditingController();
  late Future<bool> dbExists;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    dbExists = _checkIfDatabaseExistsAndInitialized();
  }

  Future<bool> _checkIfDatabaseExistsAndInitialized() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = docDirectory.listSync();

    for (FileSystemEntity file in files) {
      if (file.path.endsWith(".db")) {
        DatabaseHelper.dbPath = file.path;
        return true;
      }
    }

    await storage.delete(key: "db_path");
    await storage.delete(key: "db_password");

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
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
              body: SingleChildScrollView(child: _loginForm()),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, "/register");
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/icon.jpg", height: 250.0, width: 250.0),
          const SizedBox(height: 30.0),
          TextField(
            cursorColor: Colors.black,
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 0.0),),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),),
              labelText: "Password",
              labelStyle: const TextStyle(color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                color: Colors.black,
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () => _login(context),
            child: const Text("Log In", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20.0),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, "/register"),
            child: const Text("Create/Import Database", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _login(BuildContext context) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      _showErrorMessage(context, "Empty password");
      return;
    }

    if (DatabaseHelper.dbPath != null) {
      bool passwordCorrect = await DatabaseHelper.validatePassword(DatabaseHelper.dbPath!, password);
      if (!passwordCorrect) {
        // ignore: use_build_context_synchronously
        _showErrorMessage(context, "Incorrect password");
        return;
      }
    } else {
      _showErrorMessage(context, "Database path not found");
      return;
    }

    await DatabaseHelper.db(password);
    MyApp.dbPassword = password;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notificationPayload = prefs.getString('notificationPayload');
    if (notificationPayload != null) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ContactsDetailPage(id: int.parse(notificationPayload)),
        ),
      );
      await prefs.remove('notificationPayload');  // Clear the payload
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, "/home");
    }
  }



  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
