<<<<<<< HEAD
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
  Future<bool>? dbExists;

  @override
  void initState() {
    super.initState();
    dbExists = _checkIfDatabaseExistsAndInitialized();
  }

  Future<bool> _checkIfDatabaseExistsAndInitialized() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();

    // Lista todos los archivos en el directorio de la aplicación
    List<FileSystemEntity> files = docDirectory.listSync();

    // Comprueba si hay algún archivo de base de datos
    for (FileSystemEntity file in files) {
      if (file.path.endsWith('.db')) {
        // Si se encuentra un archivo de base de datos, establece la ruta en DatabaseHelper y devuelve true
        DatabaseHelper.dbPath = file.path;
        return true;
      }
    }

    // Si no se encuentra ningún archivo de base de datos, borra las claves de almacenamiento y devuelve false
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
            // Si la base de datos existe, muestra la pantalla de inicio de sesión
            return Scaffold(
              appBar: AppBar(title: Text('Login')),
              body: Center(child: _loginButton()),
            );
          } else {
            // Si la base de datos no existe, redirige al usuario a la pantalla de registro
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/register');
            });
            return SizedBox.shrink(); // Devuelve un widget vacío mientras se realiza la redirección
          }
        } else {
          // Mientras la comprobación de la base de datos está en progreso, muestra un indicador de progreso
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }


  Widget _loginButton() {
    return ElevatedButton(
      onPressed: () => _login(context),
      child: Text('Iniciar sesión'),
    );
  }

  void _login(BuildContext context) async {
    final password = await _askPassword(context);
    if (password == null || password.isEmpty) {
      _showErrorMessage(context, 'Acción cancelada o contraseña vacía');
      return;
    }

    if (DatabaseHelper.dbPath != null) {
      bool passwordCorrect = await DatabaseHelper.validatePassword(DatabaseHelper.dbPath!, password);
      if (!passwordCorrect) {
        _showErrorMessage(context, 'Contraseña incorrecta');
        return;
      }
    } else {
      _showErrorMessage(context, 'Ruta de la base de datos no encontrada');
      return;
    }

    await DatabaseHelper.db(password);
    MyApp.dbPassword = password; // Store the password
    Navigator.pushReplacementNamed(context, '/home');
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

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
=======
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
  Future<bool>? dbExists;

  @override
  void initState() {
    super.initState();
    dbExists = _checkIfDatabaseExistsAndInitialized();
  }

  Future<bool> _checkIfDatabaseExistsAndInitialized() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();

    // Lista todos los archivos en el directorio de la aplicación
    List<FileSystemEntity> files = docDirectory.listSync();

    // Comprueba si hay algún archivo de base de datos
    for (FileSystemEntity file in files) {
      if (file.path.endsWith('.db')) {
        // Si se encuentra un archivo de base de datos, establece la ruta en DatabaseHelper y devuelve true
        DatabaseHelper.dbPath = file.path;
        return true;
      }
    }

    // Si no se encuentra ningún archivo de base de datos, borra las claves de almacenamiento y devuelve false
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
            // Si la base de datos existe, muestra la pantalla de inicio de sesión
            return Scaffold(
              appBar: AppBar(title: Text('Login')),
              body: Center(child: _loginButton()),
            );
          } else {
            // Si la base de datos no existe, redirige al usuario a la pantalla de registro
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/register');
            });
            return SizedBox.shrink(); // Devuelve un widget vacío mientras se realiza la redirección
          }
        } else {
          // Mientras la comprobación de la base de datos está en progreso, muestra un indicador de progreso
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }


  Widget _loginButton() {
    return ElevatedButton(
      onPressed: () => _login(context),
      child: Text('Iniciar sesión'),
    );
  }

  void _login(BuildContext context) async {
    final password = await _askPassword(context);
    if (password == null || password.isEmpty) {
      _showErrorMessage(context, 'Acción cancelada o contraseña vacía');
      return;
    }

    if (DatabaseHelper.dbPath != null) {
      bool passwordCorrect = await DatabaseHelper.validatePassword(DatabaseHelper.dbPath!, password);
      if (!passwordCorrect) {
        _showErrorMessage(context, 'Contraseña incorrecta');
        return;
      }
    } else {
      _showErrorMessage(context, 'Ruta de la base de datos no encontrada');
      return;
    }

    await DatabaseHelper.db(password);
    MyApp.dbPassword = password; // Store the password
    Navigator.pushReplacementNamed(context, '/home');
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

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
>>>>>>> master
}