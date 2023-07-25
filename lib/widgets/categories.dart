// categories.dart
import 'package:flutter/material.dart';
import 'package:personaldb/categories/category_cooking.dart';
import 'package:personaldb/categories/category_ideas.dart';
import 'package:personaldb/categories/category_health.dart';
import 'package:personaldb/categories/category_personal.dart';
import 'package:personaldb/categories/category_restaurant.dart';
import 'package:personaldb/categories/category_wishlist.dart';
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
            icon: const Icon(Icons.settings, color: Colors.black,),
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

        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ));
  }

  Widget _buildBody(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final appBarHeight = AppBar().preferredSize.height;
    const bottomNavBarHeight = kBottomNavigationBarHeight;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final gridHeight = screenHeight - appBarHeight - bottomPadding - bottomNavBarHeight;
    final gridWidth = screenWidth;

    const crossAxisCount = 2;
    const double crossAxisSpacing = 10.0;
    const double mainAxisSpacing = 10.0;
    final numberOfItems = categoryList.length;
    final numberOfRows = (numberOfItems / crossAxisCount).ceil();
    final heightOfOneRow = (gridHeight - ((numberOfRows - 1) * mainAxisSpacing)) / numberOfRows;

    final childAspectRatio = gridWidth / (crossAxisCount * heightOfOneRow);

    return GridView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: categoryList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildCategory(context, categoryList[index]),
    );
  }

  Widget _buildCategory(BuildContext context, MyCategory myCategory) {
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
        child: Container (
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: myCategory.bgColor, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(myCategory.iconData, color: myCategory.iconColor, size: 90,),
                const SizedBox(height: 5,),
                FittedBox(
                  child: Text(myCategory.title!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: myCategory.iconColor), ),
                ),
              ],
            )
        )
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
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
