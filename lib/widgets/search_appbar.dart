import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool enableOrdering;
  final Function(String)? onOrderSelected;

  const SearchAppBar({super.key,
    required this.searchController,
    required this.focusNode,
    this.enableOrdering = false,
    this.onOrderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: enableOrdering ? _buildSortMenu(context) : _buildSearchIcon(),
      title: _buildSearchField(),
    );
  }

  IconButton _buildSearchIcon() {
    return const IconButton(
      icon: Icon(Icons.search, color: Colors.black),
      onPressed: null,
    );
  }

  Widget _buildSortMenu(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.sort, color: Colors.black),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text("Sort by Name"),
                  onTap: () => _selectOrderOption(context, "Name"),
                ),
                ListTile(
                  leading: const Icon(Icons.label_outline_rounded),
                  title: const Text("Sort by Label"),
                  onTap: () => _selectOrderOption(context, "Label"),
                ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Sort by Remind Me'),
                  onTap: () => _selectOrderOption(context, 'Remind Me'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectOrderOption(BuildContext context, String value) {
    Navigator.of(context).pop();
    onOrderSelected!(value);
  }

  TextField _buildSearchField() {
    return TextField(
      controller: searchController,
      focusNode: focusNode,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "Search...",
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            searchController.clear();
          },
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
