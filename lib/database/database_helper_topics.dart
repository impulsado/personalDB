// database_helper_topics.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sql;
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/database/database_helper_common.dart';

class TopicsDatabaseHelper implements DatabaseHelperCommon {
  @override
  Future<int> createItem(Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final id = await db.insert("topics", data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  @override
  Future<int> updateItem(int id, Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.update("topics", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getItems(String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("topics", orderBy: "id");
  }

  @override
  Future<List<Map<String, dynamic>>> getItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("topics", where: "id = ?", whereArgs: [id], limit: 1);
  }

  @override
  Future<void> deleteItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    try {
      await db.delete("topics", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future<List<Map<String, dynamic>>> getTopicsByContactId(int contactId, String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("topics", where: "contact_id = ?", whereArgs: [contactId], orderBy: "id");
  }
}
