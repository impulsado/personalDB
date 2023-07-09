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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _createDatabase(context),
              child: Text('Crear nueva base de datos'),
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

  void _createDatabase(BuildContext context) async {
    final newPath = await _askCreateDatabase(context);
    if (newPath == null) {
      return;
    }

    final password = await DatabaseHelper.askPassword(context);
    if (password == null || password.isEmpty) {
      _showErrorMessage(context, 'Acción cancelada o contraseña vacía');
      return;
    }

    try {
      await DatabaseHelper.createDb(newPath, password);
      Navigator.pushReplacementNamed(context, '/login'); // Aquí
    } catch (e) {
      _showErrorMessage(context, 'Error al crear la base de datos: $e');
    }
  }

  void _importDatabase(BuildContext context) async {
    final newPath = await _askImportDatabase(context);
    if (newPath == null) {
      return;
    }

    final password = await DatabaseHelper.askPassword(context);
    if (password == null || password.isEmpty) {
      _showErrorMessage(context, 'Acción cancelada o contraseña vacía');
      return;
    }

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appStoragePath = appDocDir.path;

      // Crea un nuevo archivo en el almacenamiento de la aplicación con el mismo nombre que el archivo importado
      File importedDbFile = File(newPath);
      String newDbPath = '$appStoragePath/${importedDbFile.path.split('/').last}';
      await importedDbFile.copy(newDbPath);

      // Actualiza la ruta de la base de datos en DatabaseHelper a la nueva ubicación
      DatabaseHelper.dbPath = newDbPath;

      await DatabaseHelper.db(password);
      Navigator.pushReplacementNamed(context, '/login'); // Aquí
    } catch (e) {
      _showErrorMessage(context, 'Contraseña incorrecta o error al importar la base de datos: $e');
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
