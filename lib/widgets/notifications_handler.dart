import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    var initializationSettingsAndroid =
    const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid,);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onSelectNotification);
  }

  static Future onSelectNotification(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('notificationPayload', payload);  // Store the payload for later use
    }
  }

  // CONTACT NOTIFICATION
  static Future<void> scheduleNotification(String name, String remindMeOption, int contactId) async {
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

    int remindMeInDays;
    switch (remindMeOption) {
      case "1 week":
        remindMeInDays = 7;
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
      await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          "$remindMeInDays days since last update!",
          "Click to remember $name's topics",
          tz.TZDateTime.now(tz.local).add(Duration(days: remindMeInDays)),
          platformChannelSpecifics,
          payload: contactId.toString(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
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
        "TEST",
        "TEST",
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
      icon: 'ic_launcher',
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
}
