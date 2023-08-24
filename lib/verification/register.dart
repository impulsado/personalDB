import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart' as crypto;
import 'package:archive/archive.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:personaldb/constants/colors.dart';
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
          Image.asset("assets/images/icon.png", height: 250.0, width: 250.0),
          const SizedBox(height: 30.0),
          _inputPassword
              ? TextField(
            obscureText: _obscureText,
            controller: _passwordController,
            cursorColor: Colors.grey,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.0),),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),),
              labelText: "Password",
              labelStyle: const TextStyle(color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
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
                backgroundColor: kYellowLight,
              ),
              onPressed: () {
                setState(() {
                  _inputPassword = true;
                });
              },
              child: const Text("Create New Database", style: TextStyle(color: Colors.black)),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50.0,
            margin: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _inputPassword ? kGreenLight : kGrayLight,
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
              child: Text(
                _inputPassword ? "Confirm" : "Import Existing Database",
                style: TextStyle(color: _inputPassword ? Colors.black : kGrayDark),
              ),
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

  Future<void> _selectDatabase(BuildContext context) async {
    final newFilePath = await FilePicker.platform.pickFiles(type: FileType.any);
    if (newFilePath != null && newFilePath.files.single.path != null) {
      _filePath = newFilePath.files.single.path!;
      setState(() {
        _inputPassword = true;
      });
    }
  }

  Future<void> _importDatabase(BuildContext context, String password) async {
    try {
      // Decrypt the file
      final decryptedFile = await decryptFile(File(_filePath), password);
      final appDocDir = await getApplicationDocumentsDirectory();

      // Decompress the files
      final decompressedFiles = await decompressFiles(decryptedFile);
      final newDbPath = "${appDocDir.path}/personalDB.db";

      final assetsDir = Directory("${appDocDir.path}/assets");
      if (await assetsDir.exists()) {
        await assetsDir.delete(recursive: true);
      }
      await assetsDir.create();

      for (final file in decompressedFiles) {
        final fileName = path.basename(file.path);
        if (!fileName.startsWith("flutter_assets") &&
            !fileName.startsWith("res_time") &&
            fileName != "personalDB.db") {
          await file.rename("${assetsDir.path}/$fileName");
        }
      }

      // Import the database
      await DatabaseHelper.importDb(newDbPath, password);

      // Update MyApp.dbPassword
      MyApp.dbPassword = password;

      // Navigate to the home screen
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      _showErrorMessage(context, "Error while importing database: $e");
    }
  }

// Function to unarchive a ZIP file to a specific directory
  Future<void> unarchiveFile(File zipFile, String outputPath) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final filename = file.name;
      final data = file.content as List<int>;
      final path = "$outputPath/$filename";
      await File(path).writeAsBytes(data);
    }
  }

  Future<File> decryptFile(File file, String password) async {
    final bytes = await file.readAsBytes();

    // Hash the password using SHA-256 to get a 256-bit key
    final keyBytes = crypto.sha256.convert(utf8.encode(password)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes)); // Convert to Uint8List

    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decryptedData = encrypter.decryptBytes(encrypt.Encrypted(bytes), iv: iv);
    final outputFile = File("${file.path}.dec");
    await outputFile.writeAsBytes(decryptedData);
    return outputFile;
  }

  Future<List<File>> decompressFiles(File file) async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final appDocDir = await getApplicationDocumentsDirectory();
    final List<File> files = [];

    for (final archiveFile in archive) {
      final filename = archiveFile.name;
      final data = archiveFile.content as List<int>;
      final path = "${appDocDir.path}/$filename";
      final outputFile = await File(path).create(recursive: true);
      await outputFile.writeAsBytes(data);
      files.add(outputFile);
    }

    return files;
  }

  Future<String?> _askCreateDatabase(BuildContext context) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;
    final dbFilePath = "$path/personalDB.db";
    final existingDbFile = File(dbFilePath);

    if (await existingDbFile.exists()) {
      await existingDbFile.delete();
    }

    final newDbFile = await File(dbFilePath).create();
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