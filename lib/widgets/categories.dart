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

class Categories extends StatelessWidget {
  final categoryList = MyCategory.generateCategory();

  Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final appBarHeight = AppBar().preferredSize.height;
    final bottomNavBarHeight = kBottomNavigationBarHeight; // added this
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the available height and width for the grid
    final gridHeight = screenHeight - appBarHeight - bottomPadding - bottomNavBarHeight; // modified this line
    final gridWidth = screenWidth;

    // Calculate the aspect ratio for grid items
    final crossAxisCount = 2;
    final double crossAxisSpacing = 10.0;
    final double mainAxisSpacing = 10.0;
    final numberOfItems = categoryList.length;
    final numberOfRows = (numberOfItems / crossAxisCount).ceil();
    final heightOfOneRow = (gridHeight - ((numberOfRows - 1) * mainAxisSpacing)) / numberOfRows;

    final childAspectRatio = gridWidth / (crossAxisCount * heightOfOneRow);

    return GridView.builder(
      padding: EdgeInsets.all(15),
      itemCount: categoryList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      physics: NeverScrollableScrollPhysics(), // añade esta línea
      itemBuilder: (context, index) => _buildCategory(context, categoryList[index]),
    );
  }

  Widget _buildCategory(BuildContext context, MyCategory myCategory) {
    return GestureDetector(
        onTap: () {
          Widget page;
          switch (myCategory.title) {
            case 'Cooking':
              page = CategoryCooking(myCategory);
              break;
            case 'Ideas':
              page = CategoryIdeas(myCategory);
              break;
            case 'Health':
              page = CategoryHealth(myCategory);
              break;
            case 'Personal':
              page = CategoryPersonal(myCategory);
              break;
            case 'Restaurant':
              page = CategoryRestaurant(myCategory);
              break;
            case 'Wish List':
              page = CategoryWishList(myCategory);
              break;
            case 'Entertainment':
              page = CategoryEntertainment(myCategory);
              break;
            case 'Others':
              page = CategoryOthers(myCategory);
              break;
            default:
              throw Exception('Unsupported category: ${myCategory.title}');
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
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
}
