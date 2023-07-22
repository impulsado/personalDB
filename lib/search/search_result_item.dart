// search_result_item.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/notes/note_cooking.dart';
import 'package:personaldb/widgets/notes/note_health.dart';
import 'package:personaldb/widgets/notes/note_restaurant.dart';
import 'package:personaldb/widgets/notes/note_wishlist.dart';
import 'package:personaldb/widgets/notes/note_entertainment.dart';
import 'package:personaldb/widgets/notes/note_others.dart';
import 'package:personaldb/widgets/notes/note_personal.dart';
import 'package:personaldb/widgets/notes/notes_ideas.dart';

class SearchResultItem extends StatelessWidget {
  final Map<String, dynamic> note;
  final Color backgroundColor;
  final Function(Map<String, dynamic>) onTap;

  SearchResultItem({
    required this.note,
    required this.backgroundColor,
    required this.onTap,
  });

  Widget _buildNoteWidget() {
    switch (note["category_name"]) {
      case "Ideas":
        return NoteIdeas(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "Cooking":
        return NoteCooking(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "Health":
        return NoteHealth(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "Personal":
        return NotePersonal(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "Restaurant":
        return NoteRestaurant(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "WishList":
        return NoteWishlist(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "Entertainment":
        return NoteEntertainment(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "Others":
        return NoteOthers(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
    // Agrega aquí los casos para otras categorías...
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(note),
      child: _buildNoteWidget(),
    );
  }
}