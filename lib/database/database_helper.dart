import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "personal.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
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
          description TEXT
        )
      """,
      "Personal": """
        CREATE TABLE personal(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          description TEXT
        )
      """,
      "Restaurant": """
        CREATE TABLE restaurant(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          title TEXT,
          description TEXT,
          rating INTEGER
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