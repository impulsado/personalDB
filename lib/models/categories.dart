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
        title: "Ideas",
        bgColor: kYellowLight,
        iconColor: kYellowDark,
      ),
      MyCategory(iconData: Icons.rice_bowl_outlined,
        title: "Cooking",
        bgColor: kPinkLight,
        iconColor: kPinkDark,
      ),
      MyCategory(iconData: Icons.medical_services_outlined,
        title: "Health",
        bgColor: kGreenLight,
        iconColor: kGreenDark,
      ),
      MyCategory(iconData: Icons.person_2_outlined,
        title: "Personal",
        bgColor: kPurpleLight,
        iconColor: kPurpleDark,
      ),
      MyCategory(iconData: Icons.restaurant_outlined,
        title: "Restaurant",
        bgColor: kBlueLight,
        iconColor: kBlueDark,
      ),
      MyCategory(iconData: Icons.receipt_long,
        title: "Wish List",
        bgColor: kOrangeLight,
        iconColor: kOrangeDark,
      ),
      MyCategory(iconData: Icons.vpn_key_outlined,
        title: "Passwords",
        bgColor: kDarkBlueLight,
        iconColor: kDarkBlueDark,
      ),
      MyCategory(iconData: Icons.inventory_2_outlined,
        title: "Inventory",
        bgColor: kBrownLight,
        iconColor: kBrownDark,
      ),
      MyCategory(iconData: Icons.confirmation_number_outlined,
        title: "Entertainment",
        bgColor: kRedLight,
        iconColor: kRedDark,
      ),
      MyCategory(iconData: Icons.more_horiz_rounded,
        title: "Others",
        bgColor: kGrayLight,
        iconColor: kGrayDark,
      ),
    ];
  }
}
