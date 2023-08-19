// database_helper.dart
import 'package:sqflite_sqlcipher/sqflite.dart' as sql;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class DatabaseHelper {
  static String? dbPath;

  static Future<sql.Database> db(String password) async {
    if (dbPath == null) {
      throw Exception("Database not found.");
    }

    if (password.isEmpty) {
      throw Exception("Password not found.");
    }

    sql.Database database = await sql.openDatabase(
      dbPath!,
      version: 2,
      password: password,
      onCreate: (sql.Database db, int version) async {
        await createTables(db);
      },
      onUpgrade: (sql.Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute("""
            CREATE TABLE CheckList(
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              title TEXT,
              duration TEXT,
              price TEXT,
              notes TEXT,
              createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
          """);
          await db.execute("""
            CREATE TABLE CheckListItems(
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              checklist_id INTEGER,
              title TEXT,
              description TEXT,
              createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
              FOREIGN KEY(checklist_id) REFERENCES CheckList(id)
            )
          """);
          await db.execute("""
            CREATE TABLE vehicles(
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              name TEXT,
              registration TEXT,
              next_maintenance TEXT,
              remindMe TEXT, 
              location TEXT,
              notes TEXT,
              createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
          """);
        }
      },
    );

    return database;
  }

  static Future<void> createDb(String path, String password) async {
    dbPath = path;
    sql.Database db = await sql.openDatabase(
      path,
      version: 2,
      password: password,
      onCreate: (sql.Database db, int version) async {
        await createTables(db);
      },
    );
    await db.close();
  }

  static Future<void> importDb(String path, String password) async {
    try {
      if (await validatePassword(path, password)) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appStoragePath = appDocDir.path;

        // Create a new file in the app storage with the same name as the imported file
        File importedDbFile = File(path);
        String newDbPath = '$appStoragePath/${importedDbFile.path.split('/').last}';
        await importedDbFile.copy(newDbPath);

        // Update the db path in DatabaseHelper to the new location
        DatabaseHelper.dbPath = newDbPath;
      } else {
        throw Exception("Incorrect password or error while importing database.");
      }
    } catch (e) {
      throw Exception("Error while importing the database: $e");
    }
  }

  static Future<bool> validatePassword(String path, String password) async {
    sql.Database? db;

    try {
      db = await sql.openReadOnlyDatabase(
        path,
        password: password,
      );
      await db.rawQuery("SELECT * FROM sqlite_master LIMIT 1");
      return true;
    } catch (e) {
      // Incorrect password. Unable to open the database.
      return false;
    } finally {
      await db?.close();
    }
  }

  static Future<void> exportDatabase() async {
    final dbDirectory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> dbFiles = dbDirectory.listSync();
    dbFiles = dbFiles.where((element) => element.path.endsWith(".db")).toList();

    if (dbFiles.isEmpty) {
      //print("No database file found");
      return;
    }

    List<XFile> xFiles = dbFiles.map((file) => XFile(file.path)).toList();
    await Share.shareXFiles(xFiles, text: "My Database");
  }

  static final Map<String, List<String>> searchColumns = {
    "Ideas": ["title", "category", "description"],
    "Cooking": ["title", "duration", "ingredients", "recipe", "price"],
    "Health": ["title", "category", "description"],
    "Personal": ["title", "category", "description"],
    "Restaurant": ["title", "location", "type", "price", "notes"],
    "WishList": ["title", "link", "price", "priority", "notes"],
    "Passwords": ["title", "username", "link", "notes"],
    "Inventory": ["item", "quantity", "price", "location", "notes"],
    "Entertainment": ["title", "author", "link", "notes"],
    "Others": ["title", "description"],
    "Contacts": ["name", "birthday", "phone", "label", "address", "remindMe", "notes"],
    "CheckList": ["title", "notes"],
    "Vehicles": ["name", "registration", "notes"]
  };

  static Future<List<Map<String, dynamic>>> searchItems(String query, String password) async {
    final db = await DatabaseHelper.db(password);
    List<Map<String, dynamic>> results = [];

    //print("Searching: $query");

    for (final table in searchColumns.keys) {
      var queryString = searchColumns[table]!.map((column) => '$column LIKE ?').join(' OR ');
      var queryArgs = List<String>.generate(searchColumns[table]!.length, (index) => '%$query%');
      final result = await db.rawQuery('SELECT *, "$table" AS category_name FROM $table WHERE $queryString', queryArgs);

      //print("Table $table results: ${result.length}");

      results.addAll(result);
    }
    //print("All results: ${results.length}");
    return results;
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
          price TEXT,
          rate TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Health": """
        CREATE TABLE health(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          category TEXT,
          description TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Personal": """
        CREATE TABLE personal(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          category TEXT,
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
    "Passwords": """
        CREATE TABLE passwords(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          username TEXT,
          password TEXT,
          link TEXT,
          notes TEXT,
          lastModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
    "Inventory": """
        CREATE TABLE inventory(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          item TEXT,
          quantity TEXT,
          price TEXT,
          location TEXT,
          notes TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Entertainment": """
        CREATE TABLE Entertainment(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          author TEXT,
          link TEXT,
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
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Contacts": """
        CREATE TABLE contacts(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name TEXT,
          birthday TEXT, 
          email TEXT, 
          phone TEXT, 
          label TEXT,
          address TEXT, 
          remindMe TEXT, 
          notes TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "Topics": """
        CREATE TABLE topics(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          contact_id INTEGER,
          title TEXT,
          description TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(contact_id) REFERENCES contacts(id)
        )
      """,
      "CheckList": """
        CREATE TABLE CheckList(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          duration TEXT,
          price TEXT,
          notes TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
      "CheckListItems": """
        CREATE TABLE CheckListItems(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          checklist_id INTEGER,
          title TEXT,
          description TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(checklist_id) REFERENCES CheckList(id)
        )
      """,
      "Vehicles": """
        CREATE TABLE vehicles(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name TEXT,
          registration TEXT,
          next_maintenance TEXT,
          remindMe TEXT,
          location TEXT,
          notes TEXT,
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """,
    };

    for (String category in categories.keys) {
      await database.execute(categories[category]!);
    }
  }
}