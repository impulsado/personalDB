// delete_note.dart
import 'package:flutter/material.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/database/database_helper_factory.dart';

class DeleteButton extends StatelessWidget {
  final Map<String, dynamic> note;
  final String categoryName;
  final VoidCallback onConfirmed;

  DeleteButton({Key? key, required this.note, required this.categoryName, required this.onConfirmed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Cambiado a GestureDetector
      onTap: () => _deleteNoteConfirmation(context), // OnTap en lugar de onPressed
      child: Icon(Icons.close), // Icon en lugar de IconButton
    );
  }

  void _deleteNoteConfirmation(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(categoryName);
      await dbHelper.deleteItem(note['id'], MyApp.dbPassword!);
      await Future.delayed(const Duration(milliseconds: 250));
      onConfirmed();
    }
  }
}
