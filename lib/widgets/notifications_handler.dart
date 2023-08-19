// notifications_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    var initializationSettingsAndroid = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid,);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onSelectNotification);
  }

  static Future onSelectNotification(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("notificationPayload", payload);
    }
  }

  // TEST NOTIFICATION (Used to show allow notification pop-up)
  static Future<void> testNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "test_reminder_id",
      "Test Reminder",
      channelDescription: "Channel for test reminder notification",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: "ic_launcher",
      color: Colors.black,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,);

    await flutterLocalNotificationsPlugin.show(
        0,
        "Welcome aboard!",
        "Discover what personalDB can do for you.",
        platformChannelSpecifics
    );
  }

  // PRIVACY NOTIFICATION
  static Future<void> privacyNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "privacy_id",
      "Privacy Reminder",
      channelDescription: "Channel for privacy notification",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: "ic_launcher",
      color: Colors.black,
      styleInformation: BigTextStyleInformation(
        "No one will ever have access to your data. Remember your password as it cannot be recovered.",
        htmlFormatBigText: true,
        contentTitle: "Your Privacy First!",
        htmlFormatContentTitle: true,
      ),
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Your Privacy First!",
        "No one will ever have access to your data. Remember your password as it cannot be recovered.",
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  // BIRTHDAY NOTIFICATION
  static Future<void> showBirthdayNotification(String name) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "birthday_id",
      "Birthday Reminder",
      channelDescription: "Channel for birthday reminder",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: "ic_launcher",
      color: Colors.black,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,);

    await flutterLocalNotificationsPlugin.show(
        0,
        "Birthday Reminder",
        "Today is $name's birthday!",
        platformChannelSpecifics,
        payload: "Birthday for $name"
    );
  }

  // MAINTANCE NOTIFICATION
  static Future<void> showMaintanceNotification(String name) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "maintance_id",
      "Maintance Reminder",
      channelDescription: "Channel for maintance reminder",
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: "ic_launcher",
      color: Colors.black,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,);

    await flutterLocalNotificationsPlugin.show(
        0,
        "Maintance Reminder",
        "Remember that in 1 month you have to maintain your vehicle!",  //TODO: Change Remember Time
        platformChannelSpecifics,
        payload: "Birthday for $name"
    );
  }
}
