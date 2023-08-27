import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/main.dart';

class DatabaseExportWidget extends StatelessWidget {
  const DatabaseExportWidget({super.key});

  Future<File> compressFiles(File dbFile, Directory assetsDir, String outputPath) async {
    final archive = Archive();
    final dbBytes = await dbFile.readAsBytes();
    archive.addFile(ArchiveFile("personalDB.db", dbBytes.length, dbBytes));

    final assetsFiles = assetsDir.listSync(recursive: true).whereType<File>();
    for (final assetFile in assetsFiles) {
      final relativePath = assetFile.path.replaceFirst(assetsDir.path, "");
      final bytes = await assetFile.readAsBytes();
      archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
    }

    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(zipData!);

    return outputFile;
  }

  Future<File> encryptFile(File file, String password) async {
    final bytes = await file.readAsBytes();
    final keyBytes = crypto.sha256.convert(utf8.encode(password)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encryptedData = encrypter.encryptBytes(bytes, iv: iv);
    final outputFile = File("${file.path}.enc");
    await outputFile.writeAsBytes(encryptedData.bytes);
    return outputFile;
  }

  Future<void> shareBackup(BuildContext context) async {
    try {
      final dbFile = File(DatabaseHelper.dbPath ?? "");
      final appDocDir = await getApplicationDocumentsDirectory();
      final assetsDir = Directory("${appDocDir.path}/assets");
      final zipFile = await compressFiles(dbFile, assetsDir, "${appDocDir.path}/personalDB");
      final encryptedFile = await encryptFile(zipFile, MyApp.dbPassword!);
      final encryptedFilePath = encryptedFile.path;

      final xFiles = [XFile(encryptedFilePath)];

      Share.shareXFiles(xFiles, text: "Backup of PersonalDB");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while sharing backup: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 0.0),
      title: const Text("Export personalDB"),
      subtitle: const Text("Export all your personalDB information"),
      onTap: () => shareBackup(context),
    );
  }
}