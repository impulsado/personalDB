abstract class DatabaseHelperCommon {
  Future<int> createItem(Map<String, dynamic> data, String password);
  Future<List<Map<String, dynamic>>> getItems(String password);
  Future<List<Map<String, dynamic>>> getItem(int id, String password);
  Future<int> updateItem(int id, Map<String, dynamic> data, String password);
  Future<void> deleteItem(int id, String password);
}
