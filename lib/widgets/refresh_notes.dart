import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/main.dart';

Future<List<Map<String, dynamic>>> refreshNotes(String category) async {
  final dbHelper = DatabaseHelperFactory.getDatabaseHelper(category);
  final data = await dbHelper.getItems(MyApp.dbPassword!);
  return data;
}
