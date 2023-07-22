// search_result.dart
import 'package:flutter/material.dart';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/search/search_result_item.dart';
import 'package:personaldb/constants/colors.dart';
import 'package:personaldb/detail/detail_factory.dart';
import 'package:personaldb/models/categories.dart';

class SearchResults extends StatefulWidget {
  final String query;
  final String password;

  SearchResults({required this.query, required this.password});

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late Future<List<Map<String, dynamic>>> _searchResults;

  @override
  void initState() {
    super.initState();
    if (widget.query.isNotEmpty) {
      _searchResults = DatabaseHelper.searchItems(widget.query, widget.password);
    }
  }

  @override
  void didUpdateWidget(covariant SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query && widget.query.isNotEmpty) {
      _searchResults = DatabaseHelper.searchItems(widget.query, widget.password);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query.isEmpty) {
      return const Center(child: Text("Search for your notes."));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink(); // Retorna un widget vacío
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index];
              return SearchResultItem(
                note: item,
                backgroundColor: getCategoryColor(item['category_name']),
                onTap: (item) => onTap(item),
              );
            },
          );
        }
      },
    );
  }

  Color getCategoryColor(String? category) {
    print("EL NOM ES: ");
    print(category);
    switch (category) {
      case 'Ideas':
        return kYellowLight;
      case 'Cooking':
        return kPinkLight;
      case 'Health':
        return kGreenLight;
      case 'Personal':
        return kPurpleLight;
      case 'Restaurant':
        return kBlueLight;
      case 'WishList':
        return kOrangeLight;
      case 'Entertainment':
        return kRedLight;
      case 'Others':
        return kGrayLight;
      default:
        return Colors.white;
    }
  }

  void onTap(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailPageFactory.getDetailPage(
              MyCategory(
                title: item['category_name'],
                bgColor: getCategoryColor(item['category_name']),
              ),
              id: item['id'],
            ),
      ),
    ).then((result) {
      if (result == "refresh") {
        _searchResults =
            DatabaseHelper.searchItems(widget.query, widget.password);
      }
    });
  }
}
