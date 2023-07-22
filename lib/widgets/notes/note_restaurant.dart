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

  NoteRestaurant({
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
              margin: EdgeInsets.only(right: 50.0, left: 13.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        note["title"] ?? "No Title",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 15),
                      Text(
                        note["type"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      SizedBox(width: 15),
                      Text(
                        note["price"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 5),
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
