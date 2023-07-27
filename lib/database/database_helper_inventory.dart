import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sql;
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/database/database_helper_common.dart';

class InventoryDatabaseHelper implements DatabaseHelperCommon {
  @override
  Future<int> createItem(Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final id = await db.insert("inventory", data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  @override
  Future<int> updateItem(int id, Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.update("inventory", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getItems(String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("inventory", orderBy: "id");
  }

  @override
  Future<List<Map<String, dynamic>>> getItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("inventory", where: "id = ?", whereArgs: [id], limit: 1);
  }

  Future<List<String>> getLocations(String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.rawQuery('SELECT DISTINCT location FROM inventory WHERE location IS NOT NULL');
    return List<String>.from(result.map((item) => item['location']));
  }

  @override
  Future<void> deleteItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    try {
      await db.delete("inventory", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
