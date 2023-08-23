import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personaldb/home/home.dart';
import 'package:personaldb/verification/register.dart';
import 'package:personaldb/verification/login.dart';
import 'package:personaldb/widgets/birthday_checker.dart';
import 'package:personaldb/widgets/notifications_handler.dart';
import 'package:personaldb/widgets/reminder_checker.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:personaldb/settings/background_backup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  try {
    Workmanager().initialize(callbackDispatcher);  // GDrive Backups
    ReminderNotifications.initialize();  // Remind Me Notifications
    BirthdayReminder.initialize();  // BirthdayReminder
  } catch  (e) {
    //NOTHING
  }

  await listFilesInAppDirectory(); // Llama a la función para listar los archivos

  runApp(const MyApp());
}

Future<void> listFilesInAppDirectory() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final assetsDir = Directory('${appDocDir.path}/assets');

  print('Listing all files in the app directory:');
  await for (var entity in appDocDir.list(followLinks: false)) {
    print(entity.path);
  }

  if (await assetsDir.exists()) {
    print('Listing all files in the assets directory:');
    await for (var entity in assetsDir.list(followLinks: false)) {
      print(entity.path);
    }
  } else {
    print('Assets directory does not exist.');
  }
}

class MyApp extends StatelessWidget {
  static String? dbPassword;
  static String? notificationPayload;

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationHandler.init();
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "personalDB",
      theme: ThemeData(),
      initialRoute: "/login",
      navigatorKey: navigatorKey,
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/home": (context) => const HomePage(),
      },
    );
  }
}