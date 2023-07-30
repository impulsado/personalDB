import 'package:flutter/material.dart';
import 'package:personaldb/categories/category_cooking.dart';
import 'package:personaldb/categories/category_ideas.dart';
import 'package:personaldb/categories/category_health.dart';
import 'package:personaldb/categories/category_personal.dart';
import 'package:personaldb/categories/category_restaurant.dart';
import 'package:personaldb/categories/category_wishlist.dart';
import 'package:personaldb/categories/category_passwords.dart';
import 'package:personaldb/categories/category_inventory.dart';
import 'package:personaldb/categories/category_entertainment.dart';
import 'package:personaldb/categories/category_others.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/settings/settings.dart';
import 'package:personaldb/constants/theme.dart';

class Categories extends StatelessWidget {
  final categoryList = MyCategory.generateCategory();

  Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Categories", style: headingStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              navigateToSettings(context);
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  void navigateToSettings(BuildContext context) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Settings(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ));
  }

  Widget _buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spaceSize = screenWidth / 20;
    final boxSize = (screenWidth - (3 * spaceSize)) / 3;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spaceSize),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRow(context, categoryList.getRange(0, 2).toList(), boxSize, spaceSize),
            SizedBox(height: spaceSize),
            _buildRow(context, categoryList.getRange(2, 4).toList(), boxSize, spaceSize),
            SizedBox(height: spaceSize),
            _buildRow(context, categoryList.getRange(4, 6).toList(), boxSize, spaceSize),
            SizedBox(height: spaceSize),
            _buildRow(context, categoryList.getRange(6, 8).toList(), boxSize, spaceSize),
            SizedBox(height: spaceSize),
            _buildRow(context, categoryList.getRange(8, 10).toList(), boxSize, spaceSize),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<MyCategory> categories, double boxSize, double spaceSize) {
    List<Widget> rowItems = [];
    for (var i = 0; i < categories.length; i++) {
      rowItems.add(_buildCategory(context, categories[i], boxSize, spaceSize));
      if (i != categories.length - 1) {
        rowItems.add(SizedBox(width: spaceSize));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowItems,
    );
  }

  Widget _buildCategory(BuildContext context, MyCategory myCategory, double boxSize, double spaceSize) {
    return GestureDetector(
      onTap: () {
        Widget page;
        switch (myCategory.title) {
          case "Cooking":
            page = CategoryCooking(myCategory);
            break;
          case "Ideas":
            page = CategoryIdeas(myCategory);
            break;
          case "Health":
            page = CategoryHealth(myCategory);
            break;
          case "Personal":
            page = CategoryPersonal(myCategory);
            break;
          case "Restaurant":
            page = CategoryRestaurant(myCategory);
            break;
          case "Wish List":
            page = CategoryWishList(myCategory);
            break;
          case "Passwords":
            page = CategoryPasswords(myCategory);
            break;
          case "Inventory":
            page = CategoryInventory(myCategory);
            break;
          case "Entertainment":
            page = CategoryEntertainment(myCategory);
            break;
          case "Others":
            page = CategoryOthers(myCategory);
            break;
          default:
            throw Exception("Unsupported category: ${myCategory.title}");
        }
        Navigator.of(context).push(_createRoute(page));
      },
      child: Container(
        width: boxSize,
        height: boxSize,
        margin: EdgeInsets.symmetric(horizontal: spaceSize / 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: myCategory.bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(myCategory.iconData, color: myCategory.iconColor, size: boxSize * 0.5,),
            const SizedBox(height: 5,),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                myCategory.title!,
                style: TextStyle(fontSize: boxSize * 0.125, fontWeight: FontWeight.bold, color: myCategory.iconColor),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
