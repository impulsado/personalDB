// search_result.dart
import 'package:flutter/material.dart';
import 'package:personaldb/database/database_helper.dart';
import 'package:personaldb/search/search_result_item.dart';
import 'package:personaldb/constants/colors.dart';
import 'package:personaldb/detail/detail_factory.dart';
import 'package:personaldb/models/categories.dart';

class SearchResults extends StatefulWidget {
  final String? query;
  final String password;

  const SearchResults({Key? key, this.query, required this.password}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late Future<List<Map<String, dynamic>>> _searchResults;

  @override
  void initState() {
    super.initState();
    if (widget.query != null && widget.query!.isNotEmpty) {
      _searchResults = DatabaseHelper.searchItems(widget.query!, widget.password);
    } else {
      _searchResults = Future.value([]);
    }
  }

  @override
  void didUpdateWidget(covariant SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query && widget.query != null && widget.query!.isNotEmpty) {
      _searchResults = DatabaseHelper.searchItems(widget.query!, widget.password);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query == null || widget.query!.isEmpty) {
      return const Center(child: Text("Search for your notes."));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.data!.isEmpty) {
          return const Center(child: Text("No results found."));
        } else {
          return GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.black,
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return SearchResultItem(
                  note: item,
                  backgroundColor: getCategoryColor(item["category_name"]),
                  onTap: (item) => onTap(item),
                );
              },
            ),
          );
        }
      },
    );
  }

  Color getCategoryColor(String? category) {
    switch (category) {
      case "Ideas":
        return kYellowLight;
      case "Cooking":
        return kPinkLight;
      case "Health":
        return kGreenLight;
      case "Personal":
        return kPurpleLight;
      case "Restaurant":
        return kBlueLight;
      case "WishList":
        return kOrangeLight;
      case "Passwords":
        return kDarkBlueLight;
      case "Inventory":
        return kBrownLight;
      case "Entertainment":
        return kRedLight;
      case "Others":
        return kGrayLight;
      case "Contacts":
        return Colors.grey.shade100;
      case "CheckList":
        return kTurquoiseLight;
      case "Vehicles":
        return kMetalDark;
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
                title: item["category_name"],
              ),
              id: item["id"],
            ),
      ),
    ).then((result) {
      if (result == "refresh") {
        if (widget.query != null && widget.query!.isNotEmpty) {
          _searchResults = DatabaseHelper.searchItems(widget.query!, widget.password);
        }
      }
    });
  }
}
