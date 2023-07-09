import 'package:sqflite_sqlcipher/sqflite.dart' as sql;
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/database/database_helper_common.dart';

class EntertainmentDatabaseHelper implements DatabaseHelperCommon {
  @override
  Future<int> createItem(Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final id = await db.insert("entertainment", data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Similar for updateItem
  @override
  Future<int> updateItem(int id, Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.update("entertainment", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getItems(String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("entertainment", orderBy: "id");
  }

  @override
  Future<List<Map<String, dynamic>>> getItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("entertainment", where: "id = ?", whereArgs: [id], limit: 1);
  }

  Future<List<String>> getAuthor(String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.rawQuery('SELECT DISTINCT author FROM entertainment WHERE author IS NOT NULL');
    return List<String>.from(result.map((item) => item['author']));
  }

  Future<List<String>> getGenre(String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.rawQuery('SELECT DISTINCT genre FROM entertainment WHERE genre IS NOT NULL');
    return List<String>.from(result.map((item) => item['genre']));
  }

  @override
  Future<void> deleteItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    await db.delete("entertainment", where: "id = ?", whereArgs: [id]);
  }
}
