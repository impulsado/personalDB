// note_entertainment.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/delete_button.dart';
import 'package:personaldb/widgets/star_rating.dart';

class NoteEntertainment extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback? onDelete;
  final String categoryName;
  final bool showDeleteButton;
  final Color backgroundColor;  // Añadir backgroundColor a NoteEntertainment

  NoteEntertainment({
    Key? key,
    required this.note,
    this.onDelete,
    required this.categoryName,
    this.showDeleteButton = true,
    required this.backgroundColor,  // Hacer backgroundColor requerido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,  // Usar backgroundColor para el color de fondo
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(right: 50.0, left: 13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note["title"] ?? "No Title",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        note["author"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    StarRating(
                      initialValue: double.parse(note["rate"] ?? "0"),
                      onChanged: (value) {},
                      itemSize: 20,
                      isReadOnly: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showDeleteButton)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: DeleteButton(note: note, categoryName: categoryName, onConfirmed: onDelete!),
            ),
        ],
      ),
    );
  }
}
