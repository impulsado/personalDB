import 'package:sqflite_sqlcipher/sqflite.dart' as sql;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class DatabaseHelper {
  static String? dbPath;

  static Future<sql.Database> db(String password) async {
    if (dbPath == null) {
      throw Exception('No se encontró la base de datos');
    }

    if (password.isEmpty) {
      throw Exception('No se encontró la contraseña');
    }

    sql.Database database = await sql.openDatabase(
      dbPath!,
      version: 1,
      password: password,
      onCreate: (sql.Database db, int version) async {
        await createTables(db);
      },
    );

    return database;
  }

  static Future<void> createDb(String path, String password) async {
    dbPath = path;
    sql.Database db = await sql.openDatabase(
      path,
      version: 1,
      password: password,
      onCreate: (sql.Database db, int version) async {
        await createTables(db);
      },
    );
    await db.close();
  }

  static Future<bool> validatePassword(String path, String password) async {
    sql.Database? db;

    try {
      db = await sql.openReadOnlyDatabase(
        path,
        password: password,
      );

      // Probamos a hacer una consulta a la base de datos para verificar la contraseña
      await db.rawQuery('SELECT * FROM sqlite_master LIMIT 1');

      // Si la consulta se ejecuta con éxito, la contraseña es correcta.
      return true;
    } catch (e) {
      // Si hay una excepción (por ejemplo, una excepción de SQLite), la contraseña es incorrecta.
      print('Contraseña incorrecta. No se puede abrir la base de datos.');
      return false;
    } finally {
      // Asegúrese de cerrar la base de datos para evitar fugas de memoria.
      await db?.close();
    }
  }

  static Future<String?> askPassword(BuildContext context) async {
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

  static Future<void> exportDatabase() async {
    final dbDirectory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> dbFiles = dbDirectory.listSync();
    dbFiles = dbFiles.where((element) => element.path.endsWith('.db')).toList();

    if (dbFiles.isEmpty) {
      print('No database file found');
      return;
    }

    List<XFile> xFiles = dbFiles.map((file) => XFile(file.path)).toList();
    await Share.shareXFiles(xFiles, text: 'My Database');
  }

  static Future<void> createTables(sql.Database database) async {
    Map<String, String> categories = {
        "Ideas": """
        CREATE TABLE ideas(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          date DATE,
          category TEXT,
          description TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Cooking": """
        CREATE TABLE cooking(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          duration TEXT,
          difficulty TEXT,
          ingredients TEXT,
          recipe TEXT,
          rate TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Health": """
        CREATE TABLE health(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          type TEXT,
          description TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Personal": """
        CREATE TABLE personal(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          type TEXT,
          date DATE,
          description TEXT,
          trust TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Restaurant": """
        CREATE TABLE restaurant(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          location TEXT,
          type TEXT,
          price TEXT,
          notes TEXT,
          rate TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "WishList": """
        CREATE TABLE WishList(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          link TEXT,
          price TEXT,
          priority TEXT,
          notes TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Entertainment": """
        CREATE TABLE Entertainment(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          author TEXT,
          genre TEXT,
          notes TEXT,
          rate TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Others": """
        CREATE TABLE others(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          description TEXT
        )
      """
    };

    for (String category in categories.keys) {
      await database.execute(categories[category]!);
    }
  }
}