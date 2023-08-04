import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sql;
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/database/database_helper_common.dart';
import 'dart:async';

class IdeasDatabaseHelper implements DatabaseHelperCommon {
  final StreamController<List<String>> _categoriesController = StreamController.broadcast();
  Stream<List<String>> get categoriesStream => _categoriesController.stream;

  @override
  Future<int> createItem(Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final id = await db.insert("ideas", data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

    // Actualizar la lista de categorías después de crear un nuevo elemento
    await _updateCategories(password);

    return id;
  }

  @override
  Future<int> updateItem(int id, Map<String, dynamic> data, String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.update("ideas", data, where: "id = ?", whereArgs: [id]);

    // Actualizar la lista de categorías después de actualizar un elemento
    await _updateCategories(password);

    return result;
  }

  Future<void> _updateCategories(String password) async {
    List<String> categories = await getCategories(password);
    _categoriesController.add(categories);
  }

  @override
  Future<List<Map<String, dynamic>>> getItems(String password) async {
    final db = await DatabaseHelper.db(password);
    var result = await db.query("ideas", orderBy: "id");
    return List<Map<String, dynamic>>.from(result);
  }

  @override
  Future<List<Map<String, dynamic>>> getItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    return db.query("ideas", where: "id = ?", whereArgs: [id], limit: 1);
  }

  Future<List<String>> getCategories(String password) async {
    final db = await DatabaseHelper.db(password);
    final result = await db.rawQuery("SELECT DISTINCT category FROM ideas WHERE category IS NOT NULL");
    return List<String>.from(result.map((item) => item['category']));
  }

  @override
  Future<void> deleteItem(int id, String password) async {
    final db = await DatabaseHelper.db(password);
    try {
      await db.delete("ideas", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
