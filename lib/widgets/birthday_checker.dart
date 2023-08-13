import 'package:personaldb/widgets/notifications_handler.dart';
import 'package:workmanager/workmanager.dart';

class BirthdayReminder {
  static const String _birthdayReminderTask = "birthdayReminderTask";

  static void initialize() {
    Workmanager().initialize(_birthdayCallbackDispatcher);
  }

  static void scheduleBirthdayReminder(DateTime birthday, String contactName) {
    final initialDelay = _calculateInitialDelay(birthday);
    print(initialDelay);
    Workmanager().registerOneOffTask(
      'birthdayReminder_$contactName',
      _birthdayReminderTask,
      initialDelay: initialDelay,
      inputData: <String, dynamic>{"name": contactName, "birthday": birthday.toIso8601String()},
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
      ),
    );
  }

  static Duration _calculateInitialDelay(DateTime birthday) {
    final now = DateTime.now();
    final thisYearBirthday = DateTime(now.year, birthday.month, birthday.day);
    if (thisYearBirthday.isBefore(now)) {
      final nextYearBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
      return Duration(days: nextYearBirthday.difference(now).inDays);
    } else {
      return Duration(days: thisYearBirthday.difference(now).inDays);
    }
  }
}

void _birthdayCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BirthdayReminder._birthdayReminderTask) {
      final name = inputData?["name"];
      final birthdayString = inputData?["birthday"];
      if (name != null && birthdayString != null) {
        NotificationHandler.showBirthdayNotification(name);
        DateTime nextBirthday = DateTime.parse(birthdayString);
        BirthdayReminder.scheduleBirthdayReminder(nextBirthday, name);
      }
    }
    return Future.value(true);
  });
}
