// settings.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/constants/theme.dart';

class Settings extends StatelessWidget {

  Future<String> onDatabaseLocation() async {
    return DatabaseHelper.dbPath ?? 'No database found';
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
              SizedBox(height: 20),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: headingStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () {Navigator.pop(context);},
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('General', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text('Database Location'),
                onTap: () async {
                  final location = await onDatabaseLocation();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Database Location'),
                        content: Text(location),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 15.0),
              Text('View', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text('Theme'),
                onTap: () {
                  _openDialog(context, 'Theme', 'Comming soon!');
                },
              ),
              ListTile(
                title: const Text('Language'),
                onTap: () {
                  _openDialog(context, 'Language', 'Comming soon!');
                },
              ),
              const SizedBox(height: 15.0),
              Text('Database', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text('Restore'),
                onTap: () {
                  FilePicker.platform.pickFiles(type: FileType.any);
                },
              ),
              ListTile(
                title: const Text('Export'),
                onTap: () async {
                  await DatabaseHelper.exportDatabase();
                },
              ),
              const SizedBox(height: 15.0),
              Text('Information', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text('Donate'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Donate'),
                        content: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "This application was created to help people, that's why all the code is public & free. \n",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(text: "\n"),
                              TextSpan(
                                text: "If you find it useful, you can make a donation here: \n",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(text: "\n"),
                              TextSpan(
                                text: "Buy Me a Coffee",
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.blue),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  launch('https://bmc.link/impulsado');
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
                title: const Text('About'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('About'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image(
                              image: AssetImage('assets/images/icon.jpg'),
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(height: 15),
                            Text('0.0.0', style: TextStyle(fontSize: 16),),
                            SizedBox(height: 15),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Code Repository: ',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  TextSpan(
                                    text: 'Github',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      launch('https://github.com/impulsado/personalDB');
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 15),
                            Text("© 2023 personalDB \n All rights reserved", style: TextStyle(fontSize: 16),),
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
    );
  }
}

void navigateToSettings(BuildContext context) {
  Navigator.push(context, PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Settings(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  ));
}

