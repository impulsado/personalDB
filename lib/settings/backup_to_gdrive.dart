// backup_to_gdrive.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart' hide Key;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/widgets/cupertino_picker.dart';
import 'package:workmanager/workmanager.dart';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/settings/authenticated_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personaldb/settings/background_backup.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class BackupToDrive extends StatefulWidget {
  const BackupToDrive({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BackupToDriveState createState() => _BackupToDriveState();
}

class _BackupToDriveState extends State<BackupToDrive> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
  final TextEditingController _backupFrequencyController = TextEditingController(text: "Daily");
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
      String backupFrequency = prefs.getString("backupFrequency") ?? "Daily";
      setState(() {
        _isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
        _folderId = prefs.getString("folderId");
        _backupFrequencyController.text = backupFrequency;
        _lastBackupTime = prefs.getString("lastBackupTime") != null
            ? DateTime.parse(prefs.getString("lastBackupTime")!)
            : null;
      });
      if (_isLoggedIn && backupFrequency == "Daily") {
        prefs.setString("backupFrequency", "Daily");
        _scheduleBackup();
      }
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

  Future<void> _checkAndDeleteOldBackups(String? folderId) async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null && folderId != null) {
        final authHeaders = await account.authHeaders;
        final authenticateClient = AuthenticatedClient(http.Client(), () => Future.value(authHeaders));
        final driveApi = drive.DriveApi(authenticateClient);

        final files = await driveApi.files.list(q: "'$folderId' in parents and mimeType != 'application/vnd.google-apps.folder'");

        final encFiles = files.items?.where((file) => file.title?.endsWith('.enc') ?? false).toList() ?? [];

        if (encFiles.length > 8) {
          encFiles.sort((a, b) => a.createdDate!.compareTo(b.createdDate!));
          for (int i = 0; i < encFiles.length - 8; i++) {
            await driveApi.files.delete(encFiles[i].id!);
          }
        }
      }
    } catch (e) {
      // NOTHIGN
    }
  }

  Future<void> _uploadFileToDrive(String? folderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Colors.black)),
              SizedBox(width: 10),
              Text("Backing up..."),
            ],
          ),
        );
      },
    );

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        final authHeaders = await account.authHeaders;
        final authenticateClient = AuthenticatedClient(http.Client(), () => Future.value(authHeaders));
        final driveApi = drive.DriveApi(authenticateClient);

        // Get the database file
        final dbFile = File(DatabaseHelper.dbPath ?? "");
        Directory appDocDir = await getApplicationDocumentsDirectory();

        // Get the assets folder
        final assetsDir = Directory("${appDocDir.path}/assets");

        // Compress and encrypt the files
        final zipFile = await compressFiles(dbFile, assetsDir, "${appDocDir.path}/compressed.zip");
        final encryptedFile = await encryptFile(zipFile, MyApp.dbPassword!);

        // Upload to Google Drive
        final fileToUpload = drive.File();
        final formattedDate = DateTime.now().toLocal().toString().split(".")[0].substring(0, 16);
        final formattedString = formattedDate.replaceAll(" ", "_").replaceAll("-", "_").replaceAll(":", "_");
        fileToUpload.title = "personalDB_$formattedString.enc";
        fileToUpload.parents = [drive.ParentReference(id: folderId)];
        final content = encryptedFile.openRead();
        final contentLength = await encryptedFile.length();
        await driveApi.files.insert(fileToUpload, uploadMedia: drive.Media(content, contentLength));

        await _checkAndDeleteOldBackups(folderId);

        setState(() {
          _lastBackupTime = DateTime.now();
        });
        _savePreferences();
      }
    } catch (e) {
      // Handle error
    } finally {
      Navigator.of(context).pop();
    }

    // Mostrar mensaje de éxito
    // ignore: use_build_context_synchronously
    _showSuccessMessage(context, "Database and assets backup completed successfully");
  }

  Future<File> compressFiles(File dbFile, Directory assetsDir, String outputPath) async {
    final archive = Archive();

    // Add database file
    final dbBytes = await dbFile.readAsBytes();
    archive.addFile(ArchiveFile("personalDB.db", dbBytes.length, dbBytes));

    // Compress assets folder
    final assetsFiles = assetsDir.listSync(recursive: true).whereType<File>();
    for (final assetFile in assetsFiles) {
      final relativePath = assetFile.path.replaceFirst(assetsDir.path, "");
      final bytes = await assetFile.readAsBytes();
      if (relativePath.endsWith(".jpg") ||
          relativePath.endsWith(".jpeg") ||
          relativePath.endsWith(".png") ||
          relativePath.endsWith(".bmp") ||
          relativePath.endsWith(".gif") ||
          relativePath.endsWith(".webp") ||
          relativePath.endsWith(".heif") ||
          relativePath.endsWith(".tiff")) {
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      }

    }

    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(zipData!);

    return outputFile;
  }

  Future<File> encryptFile(File file, String password) async {
    final bytes = await file.readAsBytes();

    // Hash the password using SHA-256 to get a 256-bit key
    final keyBytes = crypto.sha256.convert(utf8.encode(password)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes)); // Convert to Uint8List

    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encryptedData = encrypter.encryptBytes(bytes, iv: iv);
    final outputFile = File("${file.path}.enc");
    await outputFile.writeAsBytes(encryptedData.bytes);
    return outputFile;
  }

  void _showSuccessMessage(BuildContext context, String message) {
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
                "Last Backup: ${_lastBackupTime!.toLocal().toString().split('.')[0].substring(0, 16)}",
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