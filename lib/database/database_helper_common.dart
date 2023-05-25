abstract class DatabaseHelperCommon {
  Future<int> createItem(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getItems();
  Future<List<Map<String, dynamic>>> getItem(int id);
  Future<int> updateItem(int id, Map<String, dynamic> data);
  Future<void> deleteItem(int id);
}
