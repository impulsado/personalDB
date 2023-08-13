// reminder_checker.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class ReminderNotifications {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    Workmanager().initialize(notificationCallbackDispatcher);
    init();
  }

  static void notificationCallbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      await checkAndTriggerNotification(inputData!);
      return Future.value(true);
    });
  }

  static Future<void> init() async {
    var initializationSettingsAndroid = const AndroidInitializationSettings(
        "@mipmap/ic_launcher");
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future onSelectNotification(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("notificationPayload", payload);
    }
  }

  static Future<void> scheduleNotification(String name, String remindMeOption,
      int contactId) async {
    int remindMeInDays;
    switch (remindMeOption) {
      case "1 week":
        remindMeInDays = 1;
        break;
      case "2 weeks":
        remindMeInDays = 14;
        break;
      case "3 weeks":
        remindMeInDays = 21;
        break;
      case "4 weeks":
        remindMeInDays = 28;
        break;
      case "5 weeks":
        remindMeInDays = 35;
        break;
      case "6 weeks":
        remindMeInDays = 42;
        break;
      case "7 weeks":
        remindMeInDays = 49;
        break;
      case "8 weeks":
        remindMeInDays = 56;
        break;
      case "3 months":
        remindMeInDays = 90;
        break;
      case "4 months":
        remindMeInDays = 120;
        break;
      case "5 months":
        remindMeInDays = 150;
        break;
      case "6 months":
        remindMeInDays = 180;
        break;
      default:
        remindMeInDays = 0;
        break;
    }

    if (remindMeInDays > 0) {
      Workmanager().registerPeriodicTask(
        "id_unique_$contactId",
        "simpleTask",
        inputData: <String, dynamic>{"name": name, "contactId": contactId.toString(), "remindMeInDays": remindMeInDays},
        frequency: const Duration(days: 1), // Check every day
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: true,
        ),
      );
    }
  }

  static Future<void> showReminderNotification(String name, int contactId) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "reminder_id",
      "Reminder",
      channelDescription: "Channel for reminder notification",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: "ic_launcher",
      color: Colors.black,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,);

    await flutterLocalNotificationsPlugin.show(
      contactId,
      "Reminder",
      "Click to remember $name's topics",
      platformChannelSpecifics,
      payload: contactId.toString(),
    );
  }

  static Future<void> checkAndTriggerNotification(Map<String, dynamic> inputData) async {
    String name = inputData["name"] ?? "";
    int contactId = int.tryParse(inputData["contactId"] ?? "") ?? 0;
    int remindMeInDays = int.tryParse(inputData["remindMeInDays"] ?? "") ?? 0;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastShownDate = DateTime.tryParse(prefs.getString("lastShownDate_$contactId") ?? "") ?? DateTime(1970);

    if (DateTime.now().difference(lastShownDate).inDays >= remindMeInDays) {
      showReminderNotification(name, contactId);
      prefs.setString("lastShownDate_$contactId", DateTime.now().toIso8601String());
    }
  }
}