import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sql;
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/database/database_helper_common.dart';

class HealthDatabaseHelper implements DatabaseHelperCommon {
  @override
  Future<int> createItem(Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final id = await db.insert("health", data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  @override
  Future<int> updateItem(int id, Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.update("health", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getItems(String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("health", orderBy: "id");
  }

  @override
  Future<List<Map<String, dynamic>>> getItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("health", where: "id = ?", whereArgs: [id], limit: 1);
  }

  Future<List<String>> getTypes(String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.rawQuery('SELECT DISTINCT type FROM health WHERE type IS NOT NULL');
    return List<String>.from(result.map((item) => item['type']));
  }

  @override
  Future<void> deleteItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    try {
      await db.delete("health", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
