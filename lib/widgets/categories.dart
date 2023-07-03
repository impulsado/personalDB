import 'package:flutter/material.dart';
import 'package:personaldb/categories/category_cooking.dart';
import 'package:personaldb/categories/category_ideas.dart';
import 'package:personaldb/categories/category_health.dart';
import 'package:personaldb/categories/category_personal.dart';
import 'package:personaldb/categories/category_restaurant.dart';
import 'package:personaldb/models/categories.dart';

class Categories extends StatelessWidget {
  final categoryList = MyCategory.generateCategory();

  Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
          itemCount: categoryList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10
          ),
          itemBuilder: (context, index) => _buildCategory(context, categoryList[index])),
    );
  }

  Widget _buildCategory(BuildContext context, MyCategory myCategory) {
    return GestureDetector(
        onTap: () {
          // Aquí es donde decidimos a qué página de categoría ir en función del título de la categoría.
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
                Text(myCategory.title!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: myCategory.iconColor), )
              ],
            )
        )
    );
  }
}
