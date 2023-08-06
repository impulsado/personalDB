import 'package:flutter/material.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/database/database_helper_factory.dart';

class DeleteButton extends StatelessWidget {
  final Map<String, dynamic> item;
  final String categoryName;
  final VoidCallback onConfirmed;
  final String dialogTitle;
  final String dialogContent;
  final IconData? iconData;
  final Color? iconColor;

  const DeleteButton({
    Key? key,
    required this.item,
    required this.categoryName,
    required this.onConfirmed,
    required this.dialogTitle,
    required this.dialogContent,
    this.iconData,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _deleteItemConfirmation(context),
      child: Icon(
        iconData ?? Icons.close,
        color: iconColor ?? Colors.black,
      ),
    );
  }

  void _deleteItemConfirmation(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogContent),
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
      await dbHelper.deleteItem(item["id"], MyApp.dbPassword!);
      await Future.delayed(const Duration(milliseconds: 250));
      onConfirmed();
    }
  }
}
