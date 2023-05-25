import 'database_helper_ideas.dart';

class DatabaseHelperFactory {
  static final Map<String, dynamic> _databaseHelpers = {
    'Ideas': IdeasDatabaseHelper(),
    // Add other category database helpers here
  };

  static dynamic getDatabaseHelper(String category) {
    return _databaseHelpers[category];
  }
}
