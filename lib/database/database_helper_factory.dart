import 'package:personaldb/database/database_helper_common.dart';
import 'package:personaldb/database/database_helper_cooking.dart';
import 'package:personaldb/database/database_helper_health.dart';
import 'package:personaldb/database/database_helper_ideas.dart';
import 'package:personaldb/database/database_helper_others.dart';
import 'package:personaldb/database/database_helper_personal.dart';
import 'package:personaldb/database/database_helper_restaurant.dart';
import 'package:personaldb/database/database_helper_wishlist.dart';

class DatabaseHelperFactory {
  static final Map<String, DatabaseHelperCommon> _databaseHelpers = {
    "Ideas": IdeasDatabaseHelper(),
    "Cooking": CookingDatabaseHelper(),
    "Health": HealthDatabaseHelper(),
    "Personal": PersonalDatabaseHelper(),
    "Restaurant": RestaurantDatabaseHelper(),
    "Wish List": WishlistDatabaseHelper(),
    "Others": OthersDatabaseHelper(),
  };

  static DatabaseHelperCommon getDatabaseHelper(String category) {
    return _databaseHelpers[category]!;
  }
}
