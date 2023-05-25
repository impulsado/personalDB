import 'package:personaldb/database/database_helper_common.dart';
import 'package:personaldb/database/database_helper_cooking.dart';
import 'package:personaldb/database/database_helper_health.dart';
import 'package:personaldb/database/database_helper_ideas.dart';

class DatabaseHelperFactory {
  static final Map<String, DatabaseHelperCommon> _databaseHelpers = {
    "Ideas": IdeasDatabaseHelper(),
    "Cooking": CookingDatabaseHelper(),
    "Health": HealthDatabaseHelper(),
  };

  static DatabaseHelperCommon getDatabaseHelper(String category) {
    return _databaseHelpers[category]!;
  }
}
