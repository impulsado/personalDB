import 'package:flutter/material.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/detail/detail_ideas.dart';
import 'package:personaldb/detail/detail_cooking.dart';
import 'package:personaldb/detail/detail_health.dart';
import 'package:personaldb/detail/detail_personal.dart';

class DetailPageFactory {
  static Widget getDetailPage(MyCategory myCategory, {int? id}) {
    switch(myCategory.title) {
      case 'Ideas':
        return IdeasDetailPage(myCategory, id: id);
      case 'Cooking':
        return CookingDetailPage(myCategory, id: id);
      case 'Health':
        return HealthDetailPage(myCategory, id: id);
      case 'Personal':
        return PersonalDetailPage(myCategory, id: id);
      default:
        throw Exception('Category not found');
    }
  }
}