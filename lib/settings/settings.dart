// settings.dart
import 'package:flutter/material.dart';
import 'package:personaldb/settings/conf_fingerprint.dart';
import 'package:personaldb/settings/export_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/contacts/import_contacts.dart';
import 'package:personaldb/settings/backup_to_gdrive.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Future<String> onDatabaseLocation() async {
    return DatabaseHelper.dbPath ?? "No database found";
  }

  void _openDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.lock,
                size: 60,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 20),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  final Uri githubUrl = Uri.parse("https://github.com/impulsado/PersonalDB");
  final Uri donationUrl = Uri.parse("https://www.buymeacoffee.com/impulsado");
  final Uri portfolioUrl = Uri.parse("https://www.impulsado.org");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: headingStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () {Navigator.pop(context);},
        ),
      ),

      body: NotificationListener<OverscrollIndicatorNotification> (
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("General", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("Import Contacts"),
                  subtitle: const Text("Import local contacts to CRM"),
                  onTap: () async {
                    Navigator.of(context).push(_customPageRoute(ImportContactsWidget(password: MyApp.dbPassword!)));
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("Configure Backups"),
                  subtitle: const Text("Set up automatic Google Drive backup"),
                  onTap: () {
                    Navigator.of(context).push(_customPageRoute(const BackupToDrive()));
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("Configure Fingerprint"),
                  subtitle: const Text("Configure unlocking DB with fingerprint"),
                  onTap: () {
                    Navigator.of(context).push(_customPageRoute(const FingerprintSetupScreen()));
                  },
                ),
                Divider(color: Colors.grey.shade300, thickness: 1.0,),
                const SizedBox(height: 10.0),
                Text("Database", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("Database Location"),
                  subtitle: const Text("Internal device storage"),
                  onTap: () async {
                    final location = await onDatabaseLocation();
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Database Location"),
                          content: Text(location),
                        );
                      },
                    );
                  },
                ),
                const DatabaseExportWidget(),
                Divider(color: Colors.grey.shade300, thickness: 1.0,),
                const SizedBox(height: 10.0),
                Text("View", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("Theme"),
                  subtitle: const Text("Choose the application theme"),
                  onTap: () {
                    _openDialog(context, "Theme", "Coming soon!");
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("Language"),
                  subtitle: const Text("Select the application language"),
                  onTap: () {
                    _openDialog(context, "Language", "Coming soon!");
                  },
                ),
                Divider(color: Colors.grey.shade300, thickness: 1.0,),
                const SizedBox(height: 10.0),
                Text("Information", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("About"),
                  subtitle: const Text("View software version"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("About"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Image(
                                image: AssetImage("assets/images/icon.png"),
                                height: 100,
                                width: 100,
                              ),
                              const SizedBox(height: 15),
                              const Text("1.1.1", style: TextStyle(fontSize: 16),),
                              const SizedBox(height: 15),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Code Repository: ",
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    TextSpan(
                                      text: "GitHub",
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()..onTap = () {
                                        launchUrl(githubUrl, mode: LaunchMode.externalApplication);
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),
                              const Text("© 2023 personalDB. All rights reserved.", style: TextStyle(fontSize: 10),),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("Donate"),
                  subtitle: const Text("Support the development"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Donate"),
                          content: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "This application was created to help people, that's why all the code is public & free. \n",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const TextSpan(text: "\n"),
                                TextSpan(
                                  text: "If you find it useful, you can make a donation here: \n",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const TextSpan(text: "\n"),
                                TextSpan(
                                  text: "Buy Me a Coffee",
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    launchUrl(donationUrl, mode: LaunchMode.externalApplication);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0),
                  title: const Text("Contact Me"),
                  subtitle: const Text("Know more about impulsado"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Contact Me"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Image(
                                image: AssetImage("assets/images/impulsado.jpg"),
                                height: 100,
                                width: 100,
                              ),
                              const SizedBox(height: 10),
                              const Text("impu | 2003", style: TextStyle(fontSize: 14),),
                              const SizedBox(height: 30),
                              const Text("Autodidact born to never stop creating.", style: TextStyle(color: Colors.black,fontSize: 16),),
                              const SizedBox(height: 15),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Portfolio",
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()..onTap = () {
                                        launchUrl(portfolioUrl, mode: LaunchMode.externalApplication);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  PageRouteBuilder _customPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
