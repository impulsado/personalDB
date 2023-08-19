import 'package:flutter/material.dart';
import 'package:personaldb/detail/detail_checklists.dart';
import 'package:personaldb/detail/detail_contacts.dart';
import 'package:personaldb/detail/detail_inventory.dart';
import 'package:personaldb/detail/detail_passwords.dart';
import 'package:personaldb/detail/detail_vehicles.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/detail/detail_ideas.dart';
import 'package:personaldb/detail/detail_cooking.dart';
import 'package:personaldb/detail/detail_health.dart';
import 'package:personaldb/detail/detail_personal.dart';
import 'package:personaldb/detail/detail_restaurant.dart';
import 'package:personaldb/detail/detail_wishlist.dart';
import 'package:personaldb/detail/detail_entertainment.dart';
import 'package:personaldb/detail/detail_others.dart';

class DetailPageFactory {
  static Widget getDetailPage(MyCategory myCategory, {int? id}) {
    switch(myCategory.title) {
      case "Ideas":
        return IdeasDetailPage(myCategory, id: id);
      case "Cooking":
        return CookingDetailPage(myCategory, id: id);
      case "Health":
        return HealthDetailPage(myCategory, id: id);
      case "Personal":
        return PersonalDetailPage(myCategory, id: id);
      case "Restaurant":
        return RestaurantDetailPage(myCategory, id: id);
      case "Wish List":
        return WishlistDetailPage(myCategory, id: id);
      case "Passwords":
        return PasswordsDetailPage(myCategory, id: id);
      case "Inventory":
        return InventoryDetailPage(myCategory, id: id);
      case "Entertainment":
        return EntertainmentDetailPage(myCategory, id: id);
      case "Others":
        return OthersDetailPage(myCategory, id: id);
      case "Check List":
        return CheckListDetailPage(myCategory, id: id);
      case "Vehicles":
        return VehiclesDetailPage(id: id);
      case "Contacts":
        return ContactsDetailPage(id: id);
      default:
        throw Exception("Category not found");
    }
  }
}