// note_vehicles.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/delete_button.dart';

class NoteVehicles extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback? onDelete;
  final String categoryName;
  final bool showDeleteButton;
  final Color backgroundColor;

  const NoteVehicles({
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
                        note["name"] ?? "No Name",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        note["next_maintance"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
          if (showDeleteButton)
            Positioned(
              right: 11,
              top: 0,
              bottom: 0,
              child: DeleteButton(
                  item: note,
                  categoryName: categoryName,
                  onConfirmed: onDelete!,
                  dialogTitle: "Delete Note",
                  dialogContent: "Are you sure you want to delete this note?"
              ),
            ),
        ],
      ),
    );
  }
}
