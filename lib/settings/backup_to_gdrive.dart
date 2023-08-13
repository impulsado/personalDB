// backup_to_gdrive.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/widgets/cupertino_picker.dart';
import 'package:workmanager/workmanager.dart';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/settings/authenticated_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personaldb/settings/background_backup.dart';

class BackupToDrive extends StatefulWidget {
  const BackupToDrive({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BackupToDriveState createState() => _BackupToDriveState();
}

class _BackupToDriveState extends State<BackupToDrive> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
  final TextEditingController _backupFrequencyController = TextEditingController();
  bool _isLoggedIn = false;
  String? _folderId;
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
        _folderId = prefs.getString("folderId");
        _backupFrequencyController.text = prefs.getString("backupFrequency") ?? _backupFrequencyController.text;
        _lastBackupTime = prefs.getString("lastBackupTime") != null
            ? DateTime.parse(prefs.getString("lastBackupTime")!)
            : null;
      });
    } catch (e) {
      //NOTHING
    }
  }

  _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool("isLoggedIn", _isLoggedIn);
      prefs.setString("backupFrequency", _backupFrequencyController.text);
      if (_folderId != null) {
        prefs.setString("folderId", _folderId!);
      }
      if (_lastBackupTime != null) {
        prefs.setString("lastBackupTime", _lastBackupTime!.toIso8601String());
      }
    } catch (e) {
      //NOTHING
    }
  }

  _scheduleBackup() async {
    try {
      String dbPath = DatabaseHelper.dbPath ?? "";
      Workmanager().initialize(callbackDispatcher);
      Workmanager().cancelAll();
      Workmanager().registerPeriodicTask(
        "id_unique",
        "simplePeriodicTask",
        frequency: _getDurationFromFrequency(),
        inputData: <String, dynamic>{
          "filePath": dbPath,
        },
      );
    } catch (e) {
      //NOTHING
    }
  }

  Duration _getDurationFromFrequency() {
    switch (_backupFrequencyController.text) {
      case "Daily":
        return const Duration(days: 1);
      case "Weekly":
        return const Duration(days: 7);
      case "Monthly":
        return const Duration(days: 30);
      default:
        return const Duration(days: 365);
    }
  }

  Future<void> _createFolderInDrive() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        final authHeaders = await account.authHeaders;
        final authenticateClient = AuthenticatedClient(http.Client(), () => Future.value(authHeaders));
        final driveApi = drive.DriveApi(authenticateClient);
        final folder = drive.File();
        folder.title = "personalDB";
        folder.mimeType = "application/vnd.google-apps.folder";
        final createdFolder = await driveApi.files.insert(folder);
        _folderId = createdFolder.id;
        _savePreferences();
        _uploadFileToDrive(_folderId);
      }
    } catch (e) {
      //NOTHING
    }
  }

  Future<void> _uploadFileToDrive(String? folderId) async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        final authHeaders = await account.authHeaders;
        final authenticateClient = AuthenticatedClient(http.Client(), () => Future.value(authHeaders));
        final driveApi = drive.DriveApi(authenticateClient);
        final fileToUpload = drive.File();
        fileToUpload.title = "personalDB_${DateTime.now().toIso8601String()}";
        fileToUpload.parents = [drive.ParentReference(id: folderId)];
        final filePath = DatabaseHelper.dbPath ?? "";
        final content = File(filePath).openRead();
        Future<int> tempLength = File(filePath).length();
        int contentLength = await tempLength;
        await driveApi.files.insert(fileToUpload, uploadMedia: drive.Media(content, contentLength));
        setState(() {
          _lastBackupTime = DateTime.now();
        });
        _savePreferences();
        // ignore: use_build_context_synchronously
        _showErrorMessage(context, "Database backup completed successfully");
      }
    } catch (e) {
      //NOTHING
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Backups", style: headingStyle(color: Colors.black)),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () {Navigator.pop(context);},
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!_isLoggedIn) ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: const Text(
                        "You need to grant access to Google Drive for backups. \n"
                        "This permission is called 'drive.files' and it only has access to those files that have been generated by this application.\n\n",
                        style: TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: const Text(
                        "The application will NEVER use your Google Drive for any other purpose.",
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () async {
                            final account = await _googleSignIn.signIn();
                            if (account != null) {
                              setState(() {
                                _isLoggedIn = true;
                              });
                              await _createFolderInDrive();
                            }
                          },
                          child: const Text("Log In"),
                        ),
                        const SizedBox(width: 16.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                  if (_isLoggedIn) ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: CupertinoPickerWidget(
                        title: "Backup Frequency",
                        hint: "Select Frequency",
                        controller: _backupFrequencyController,
                        options: const ["Daily", "Weekly", "Monthly", "Stop Backups"],
                        onChanged: (value) {
                          _backupFrequencyController.text = value;
                          _savePreferences();
                          _scheduleBackup();
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child:
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () async {
                          await _uploadFileToDrive(_folderId);
                          setState(() {});
                        },
                        child: const Text("Sync Now"),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
          if (_isLoggedIn && _lastBackupTime != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Last Backup: ${_lastBackupTime!.toLocal().toString().split('.')[0]}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
