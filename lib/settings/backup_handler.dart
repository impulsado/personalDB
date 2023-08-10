// backup_handler.dart
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:personaldb/database/database_helper.dart';
import 'dart:io';

class BackupHandler {
  static String _emailAddressStatic = "";

  static void setEmail(String email) {
    _emailAddressStatic = email;
  }

  static Future<void> sendBackupEmail() async {
    final String dbPath = await DatabaseHelper.dbPath ?? "No database found";
    final File dbFile = File(dbPath);

    final Email email = Email(
      body: 'Here is your database backup.',
      subject: 'Database Backup',
      recipients: [_emailAddressStatic],
      attachmentPaths: [dbFile.path],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}