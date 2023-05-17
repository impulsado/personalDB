import 'package:flutter/material.dart';
import 'package:personaldb/constants/colors.dart';

class MyCategory {
  IconData? iconData;
  String? title;
  Color? bgColor;
  Color? iconColor;
  MyCategory({this.iconData, this.title, this.bgColor, this.iconColor});
  static List<MyCategory> generateCategory() {
    return [
      MyCategory(iconData: Icons.lightbulb_outline_rounded,
        title: 'New Ideas',
        bgColor: kYellowLight,
        iconColor: kYellowDark,
      ),
      MyCategory(iconData: Icons.rice_bowl_outlined,
        title: 'Cooking',
        bgColor: kPinkLight,
        iconColor: kPinkDark,
      ),
      MyCategory(iconData: Icons.medical_services_outlined,
        title: 'Health',
        bgColor: kGreenLight,
        iconColor: kGreenDark,
      ),
      MyCategory(iconData: Icons.person_2_outlined,
        title: 'Personal',
        bgColor: kPurpleLight,
        iconColor: kPurpleDark,
      ),
      MyCategory(iconData: Icons.restaurant_rounded,
        title: 'Restaurant',
        bgColor: kBlueLight,
        iconColor: kBlueDark,
      ),
      MyCategory(iconData: Icons.more_horiz_rounded,
        title: 'Others',
        bgColor: kGrayLight,
        iconColor: kGrayDark,
      ),
    ];
  }
}
