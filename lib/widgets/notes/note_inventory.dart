// note_inventory.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/delete_button.dart';

class NoteInventory extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback? onDelete;
  final String categoryName;
  final bool showDeleteButton;
  final Color backgroundColor;

  const NoteInventory({
    Key? key,
    required this.note,
    this.onDelete,
    required this.categoryName,
    this.showDeleteButton = true,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note["item"] ?? "No Item",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        note["location"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Text(
                  note["notes"] ?? "",
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
          if (showDeleteButton)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: DeleteButton(note: note, categoryName: categoryName, onConfirmed: onDelete!),
            ),
        ],
      ),
    );
  }
}
