import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:personaldb/database/database_helper.dart';

class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final storage = new FlutterSecureStorage();
  bool dbExists = false;

  @override
  void initState() {
    super.initState();
    _checkIfDatabaseExists();
  }

  void _checkIfDatabaseExists() async {
    String? dbPath = await storage.read(key: 'db_path');
    if (dbPath != null) {
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        DatabaseHelper.dbPath = dbPath;
        setState(() {
          dbExists = true;
        });
      } else {
        await storage.delete(key: 'db_path');
        await storage.delete(key: 'db_password');
        await storage.delete(key: 'db_accessed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storage.read(key: 'db_accessed'),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData && snapshot.data == 'true') {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final password = await _askPassword(context);
            if (password == null || password.isEmpty) {
              await storage.delete(key: 'db_accessed');
              setState(() {});
            } else {
              bool passwordCorrect = await DatabaseHelper.validatePassword(password);
              if (passwordCorrect) {
                await DatabaseHelper.db();
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                _showErrorMessage(context, 'Contraseña incorrecta');
                await storage.delete(key: 'db_accessed');
                setState(() {});
              }
            }
          });
          return Scaffold();
        } else {
          return Scaffold(
            appBar: AppBar(title: Text('Inicial')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _createOrLogin(context),
                    child: dbExists ? Text('Iniciar sesión') : Text('Crear nueva base de datos'),
                  ),
                  ElevatedButton(
                    onPressed: () => _importDatabase(context),
                    child: Text('Importar base de datos'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _createOrLogin(BuildContext context) async {
    if (!dbExists) {
      final newPath = await _askCreateDatabase(context);
      if (newPath == null) {
        return;
      }
      DatabaseHelper.dbPath = newPath;
    }
    final password = await _askPassword(context);
    if (password == null || password.isEmpty) {
      _showErrorMessage(context, 'Acción cancelada o contraseña vacía');
      return;
    }
    bool passwordCorrect = await DatabaseHelper.validatePassword(password);
    if (passwordCorrect) {
      await storage.write(key: 'db_path', value: DatabaseHelper.dbPath);
      await storage.write(key: 'db_password', value: password);
      await storage.write(key: 'db_accessed', value: 'true');
      await DatabaseHelper.db();
      Navigator.pushReplacementNamed(context, '/home');
      setState(() {
        dbExists = true;
      });
    } else {
      _showErrorMessage(context, 'Contraseña incorrecta');
    }
  }

  void _importDatabase(BuildContext context) async {
    final newPath = await _askImportDatabase(context);
    if (newPath == null) {
      return;
    }
    DatabaseHelper.dbPath = newPath;
    final password = await _askPassword(context);
    if (password == null || password.isEmpty) {
      _showErrorMessage(context, 'Acción cancelada o contraseña vacía');
      return;
    }
    bool passwordCorrect = await DatabaseHelper.validatePassword(password);
    if (passwordCorrect) {
      await storage.write(key: 'db_path', value: DatabaseHelper.dbPath);
      await storage.write(key: 'db_password', value: password);
      await storage.write(key: 'db_accessed', value: 'true');
      await DatabaseHelper.db();
      Navigator.pushReplacementNamed(context, '/home');
      setState(() {
        dbExists = true;
      });
    } else {
      _showErrorMessage(context, 'Contraseña incorrecta');
    }
  }

  Future<String?> _askPassword(BuildContext context) async {
    String? password;
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresa tu contraseña'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return TextField(
                  obscureText: true,
                  onChanged: (value) => setState(() => password = value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Contraseña',
                  ),
                );
              }
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(password),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<String?> _askCreateDatabase(BuildContext context) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final newDbFile = await File('$result/default.db').create();
      return newDbFile.path;
    }
    return null;
  }

  Future<String?> _askImportDatabase(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any);
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
