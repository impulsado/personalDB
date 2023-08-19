// maintance_checker.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class MaintanceNotifications {
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

  static Future<void> scheduleNotification(String name, String remindMeOption) async {
    int remindMeInDays;
    switch (remindMeOption) {
      case "1 day before":
        remindMeInDays = 1;
        break;
      case "1 week before":
        remindMeInDays = 7;
        break;
      case "2 week before":
        remindMeInDays = 14;
        break;
      case "1 month before":
        remindMeInDays = 30;
        break;
      case "2 months before":
        remindMeInDays = 60;
        break;
      default:
        remindMeInDays = 0;
        break;
    }

    if (remindMeInDays > 0) {
      Workmanager().registerPeriodicTask(
        "id_unique_$name",
        "simpleTask",
        inputData: <String, dynamic>{"name": name, "remindMeInDays": remindMeInDays},
        frequency: const Duration(days: 1), // Check every day
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: true,
        ),
      );
    }
  }

  static Future<void> showReminderNotification(String name) async {
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
    int notificationId = name.hashCode;

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      "Maintance",
      "Remember that $name needs maintance!",
      platformChannelSpecifics,
      payload: name.toString(),
    );
  }

  static Future<void> checkAndTriggerNotification(Map<String, dynamic> inputData) async {
    String name = inputData["name"] ?? "";
    int remindMeInDays = int.tryParse(inputData["remindMeInDays"] ?? "") ?? 0;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastShownDate = DateTime.tryParse(prefs.getString("lastShownDate_$name") ?? "") ?? DateTime(1970);

    if (DateTime.now().difference(lastShownDate).inDays >= remindMeInDays) {
      showReminderNotification(name);
      prefs.setString("lastShownDate_$name", DateTime.now().toIso8601String());
    }
  }
}