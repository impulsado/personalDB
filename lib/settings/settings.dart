import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('Export Database'),
          onPressed: () async {
            // Obtén la ubicación de la base de datos
            final dbDirectory = await getApplicationDocumentsDirectory();

            // Obtiene todos los archivos del directorio
            List<FileSystemEntity> dbFiles = dbDirectory.listSync();

            // Filtra los archivos .db
            dbFiles = dbFiles.where((element) => element.path.endsWith('.db')).toList();

            if (dbFiles.isEmpty) {
              print('No database file found');
              return;
            }

            // Crea una lista de XFiles
            List<XFile> xFiles = dbFiles.map((file) => XFile(file.path)).toList();

            // Comparte el primer archivo .db
            await Share.shareXFiles(xFiles, text: 'My Database');
          },
        ),
      ),
    );
  }
}