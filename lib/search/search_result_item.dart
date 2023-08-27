// search_result_item.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/notes/note_contacts.dart';
import 'package:personaldb/widgets/notes/note_cooking.dart';
import 'package:personaldb/widgets/notes/note_health.dart';
import 'package:personaldb/widgets/notes/note_inventory.dart';
import 'package:personaldb/widgets/notes/note_passwords.dart';
import 'package:personaldb/widgets/notes/note_restaurant.dart';
import 'package:personaldb/widgets/notes/note_wishlist.dart';
import 'package:personaldb/widgets/notes/note_entertainment.dart';
import 'package:personaldb/widgets/notes/note_others.dart';
import 'package:personaldb/widgets/notes/note_personal.dart';
import 'package:personaldb/widgets/notes/note_ideas.dart';
import 'package:personaldb/widgets/notes/note_checklists.dart';
import 'package:personaldb/widgets/notes/note_vehicles.dart';

class SearchResultItem extends StatelessWidget {
  final Map<String, dynamic> note;
  final Color backgroundColor;
  final Function(Map<String, dynamic>) onTap;

  const SearchResultItem({super.key,
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
      case "Passwords":
        return NotePasswords(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "Inventory":
        return NoteInventory(
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
      case "Contacts":
        return NoteContacts(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "CheckList":
        return NoteCheckList(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );
      case "Vehicles":
        return NoteVehicles(
          note: note,
          backgroundColor: backgroundColor,
          categoryName: note["category_name"],
          showDeleteButton: false,
        );

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