// note_cooking.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/delete_button.dart';
import 'package:personaldb/widgets/star_rating.dart';

class DifficultyRating extends StatelessWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final double itemSize;
  final bool isReadOnly;

  const DifficultyRating({super.key,
    required this.onChanged,
    this.initialValue = 0.0,
    this.itemSize = 40.0,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return index < initialValue
            ? Icon(Icons.local_fire_department, size: itemSize, color: Colors.red)
            : Icon(Icons.local_fire_department, size: itemSize, color: Colors.grey);
      }),
    );
  }
}

class NoteCooking extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback? onDelete;
  final String categoryName;
  final bool showDeleteButton;
  final Color backgroundColor;

  const NoteCooking({
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
                const SizedBox(height: 5.0),
                Text(
                  note["title"] ?? "No Title",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5.0),
                note["duration"] == "" && note["price"] == "€"
                    ? Container()
                    : Row(
                  children: [
                    Text(
                      note["duration"] ?? "",
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      note["price"] ?? "",
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    DifficultyRating(
                      initialValue: double.parse(note["difficulty"] ?? "0"),
                      onChanged: (value) {},
                      itemSize: 20,
                      isReadOnly: true,
                    ),
                    const SizedBox(width: 15),
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
              right: 11,
              top: 0,
              bottom: 0,
              child: DeleteButton(note: note, categoryName: categoryName, onConfirmed: onDelete!),
            ),
        ],
      ),
    );
  }
}
