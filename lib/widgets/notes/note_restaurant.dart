// note_restaurant.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/delete_button.dart';
import 'package:personaldb/widgets/star_rating.dart';

class NoteRestaurant extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback? onDelete;
  final String categoryName;
  final bool showDeleteButton;
  final Color backgroundColor;

  const NoteRestaurant({
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
        border: Border.all(color: Colors.black),
      ),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        note["title"] ?? "No Title",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 3,
                      child: Text(
                        note["type"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: StarRating(
                        initialValue: double.parse(note["rate"] ?? "0"),
                        onChanged: (value) {},
                        itemSize: 20,
                        isReadOnly: true,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 3,
                      child: Text(
                        note["price"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
