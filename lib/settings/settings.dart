// settings.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/contacts/import_contacts.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _filePath = "";
  bool _inputPassword = false;
  final _passwordController = TextEditingController();

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

  Future<void> _selectDatabase(BuildContext context) async {
    final newFilePath = await FilePicker.platform.pickFiles(type: FileType.any);
    if (newFilePath != null && newFilePath.files.single.path != null) {
      _filePath = newFilePath.files.single.path!;
      setState(() {
        _inputPassword = true;
      });
    }
  }

  Future<void> _importDatabaseWithPassword(BuildContext context, String password) async {
    try {
      await DatabaseHelper.importDb(_filePath, password);
      MyApp.dbPassword = password;
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      _openDialog(context, "Error", "Error while importing database: $e");
    }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("General", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
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
              ListTile(
                contentPadding: const EdgeInsets.only(left: 0.0),
                title: const Text("Import Contacts"),
                subtitle: const Text("Import local contacts to CRM"),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImportContactsWidget(password: MyApp.dbPassword!)),
                  );
                },
              ),
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
              Text("Database", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 0.0),
                title: const Text("Export"),
                subtitle: const Text("Export database for migration or security purposes"),
                onTap: () async {
                  await DatabaseHelper.exportDatabase();
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 0.0),
                title: const Text("Restore"),
                subtitle: const Text("Restore a different database with your notes"),
                onTap: () {
                  _inputPassword
                      ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Enter password"),
                        content: TextField(
                          obscureText: true,
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Password",
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _importDatabaseWithPassword(context, _passwordController.text);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  )
                      : _selectDatabase(context);
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
                              image: AssetImage("assets/images/icon.jpg"),
                              height: 100,
                              width: 100,
                            ),
                            const SizedBox(height: 15),
                            const Text("0.0.0", style: TextStyle(fontSize: 16),),
                            const SizedBox(height: 15),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Code Repository: ",
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  TextSpan(
                                    text: "Github",
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
    );
  }
}
