import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sql;

class DatabaseHelper {
  static final storage = new FlutterSecureStorage();
  static sql.Database? _database;
  static String? dbPath; // dbPath no debe tener valor por defecto

  static Future<sql.Database> db() async {
    if (_database != null) return _database!;

    // Recuperar la ruta de la base de datos y la contraseña de storage
    dbPath = await storage.read(key: 'db_path');
    String? password = await storage.read(key: 'db_password');

    if (dbPath == null || password == null) {
      throw Exception('No se encontró la base de datos o la contraseña');
    }

    _database = await sql.openDatabase(
      dbPath!, // Usamos la ruta del archivo para abrir la base de datos
      version: 1,
      password: password,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
    return _database!;
  }

  static Future<bool> validatePassword(String password) async {
    try {
      await sql.openReadOnlyDatabase(
        dbPath!, // Usamos la ruta del archivo para abrir la base de datos
        password: password,
      );
      return true;
    } on sql.DatabaseException {
      return false;
    }
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