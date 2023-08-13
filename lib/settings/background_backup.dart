// background_backup.dart
import 'dart:io';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:personaldb/settings/authenticated_client.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  try {
    Workmanager().executeTask((task, inputData) async {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
      final GoogleSignInAccount? account = await googleSignIn.signInSilently();
      if (account != null) {
        final authHeaders = await account.authHeaders;
        final authenticateClient = AuthenticatedClient(http.Client(), () => Future.value(authHeaders));
        final driveApi = drive.DriveApi(authenticateClient);
        final fileToUpload = drive.File();
        fileToUpload.title = "personalDB_${DateTime.now().toIso8601String()}";
        final filePath = inputData?["filePath"];
        final file = File(filePath);
        Future<int> tempLength = File(filePath).length();
        int contentLength = await tempLength;
        final content = file.openRead();

        await driveApi.files.insert(fileToUpload, uploadMedia: drive.Media(content, contentLength));
      }
      return Future.value(true);
    });
  } catch (e) {
    //NOTHING
  }
}

