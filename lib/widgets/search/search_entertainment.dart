import 'package:flutter/material.dart';

class SearchBarEntertainment extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool enableOrdering;
  final Function(String)? onOrderSelected;
  final Future<List<String>> Function() loadItemsFunction;
  final void Function(Map<String, bool>) onFilterChanged;

  const SearchBarEntertainment({
    Key? key,
    required this.searchController,
    required this.focusNode,
    required this.enableOrdering,
    required this.onOrderSelected,
    required this.loadItemsFunction,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchBarEntertainmentState createState() => _SearchBarEntertainmentState();
}

class _SearchBarEntertainmentState extends State<SearchBarEntertainment> {
  List<String> _categories = [];
  Map<String, bool> _categoryFilters = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _loadCategories() async {
    List<String> categories = await widget.loadItemsFunction();
    setState(() {
      _categories = categories;
      _categoryFilters = { for (var v in _categories) v : true };
    });
  }

  Widget _buildSearchIcon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(Icons.search),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: widget.searchController,
      focusNode: widget.focusNode,
      textAlignVertical: TextAlignVertical.bottom,
      decoration: InputDecoration(
        hintText: "Search...",
        border: InputBorder.none,
        suffixIcon: IconButton(
          onPressed: () => widget.searchController.clear(),
          icon: const Icon(Icons.close, color: Colors.black,),
        ),
      ),
    );
  }

  void _showOrderMenu(BuildContext context) {
    const tileHeight = 56.0; // Default ListTile height
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: tileHeight * 3,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text("Sort by Title"),
                onTap: () => _selectOrderOption(context, "Title"),
              ),
              ListTile(
                leading: const Icon(Icons.person_2_outlined),
                title: const Text("Sort by Author"),
                onTap: () => _selectOrderOption(context, "Author"),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text("Sort by Rate"),
                onTap: () => _selectOrderOption(context, "Rate"),
              ),
              ListTile(
                leading: const Icon(Icons.filter_list),
                title: const Text("Select Authors"),
                onTap: () {
                  Navigator.pop(context);
                  _showCategories(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectOrderOption(BuildContext context, String value) {
    Navigator.of(context).pop();
    widget.onOrderSelected!(value);
  }

  void _showCategories(BuildContext context) {
    const tileHeight = 56.0; // Default ListTile height
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: _categories.length * tileHeight,
              child: ListView(
                children: _categories.map((String category) {
                  return CheckboxListTile(
                    title: Text(category),
                    value: _categoryFilters[category]!,
                    activeColor: Colors.black,
                    onChanged: (bool? value) {
                      setState(() {
                        _categoryFilters[category] = value!;
                      });
                      widget.onFilterChanged(_categoryFilters);
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.enableOrdering
            ? IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _showOrderMenu(context),
        )
            : _buildSearchIcon(),
        Expanded(child: _buildSearchField()),
      ],
    );
  }
}