// background_backup.dart
import 'dart:io';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:personaldb/settings/authenticated_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
      final GoogleSignInAccount? account = await googleSignIn.signInSilently();
      if (account != null) {
        final authHeaders = await account.authHeaders;
        final authenticateClient = AuthenticatedClient(http.Client(), () => Future.value(authHeaders));
        final driveApi = drive.DriveApi(authenticateClient);

        // Get folder ID from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final folderId = prefs.getString("folderId");

        // Create the file to upload
        final fileToUpload = drive.File();
        final formattedDate = DateTime.now().toLocal().toString().split(".")[0].substring(0, 16);
        final formattedString = formattedDate.replaceAll(" ", "_").replaceAll("-", "_").replaceAll(":", "_");
        fileToUpload.title = "personalDB_$formattedString.enc";
        fileToUpload.parents = [drive.ParentReference(id: folderId)];

        // Read the file from the path provided in inputData
        final filePath = inputData?["filePath"];
        final file = File(filePath ?? "");
        final content = file.openRead();
        final contentLength = await file.length();

        // Upload the file
        await driveApi.files.insert(fileToUpload, uploadMedia: drive.Media(content, contentLength));
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}