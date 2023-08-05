import 'package:flutter/material.dart';

class SearchBarContacts extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool enableOrdering;
  final Function(String)? onOrderSelected;
  final Future<List<String>> Function() loadItemsFunction;
  final void Function(Map<String, bool>) onFilterChanged;

  SearchBarContacts({
    Key? key,
    required this.searchController,
    required this.focusNode,
    required this.enableOrdering,
    required this.onOrderSelected,
    required this.loadItemsFunction,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  _SearchBarContactsState createState() => _SearchBarContactsState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBarContactsState extends State<SearchBarContacts> {
  Map<String, bool> categoryFilters = {};

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          widget.enableOrdering
              ? IconButton(
            icon: const Icon(
              Icons.sort,
              color: Colors.black,
            ),
            onPressed: () => _showOrderMenu(context),
          )
              : _buildSearchIcon(),
          Expanded(child: _buildSearchField()),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
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
          icon: const Icon(
            Icons.close,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _showOrderMenu(BuildContext context) {
    const tileHeight = 56.0;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: tileHeight * 4,
          child: Column(
            children: <Widget>[
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
                title: const Text("Sort by Remind Me"),
                onTap: () => _selectOrderOption(context, "Remind Me"),
              ),
              ListTile(
                leading: const Icon(Icons.filter_list),
                title: const Text("Select Labels"),
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
    const tileHeight = 64.0;
    const messageHeight = 60.0;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<List<String>>(
          future: widget.loadItemsFunction(),
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: messageHeight,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return const SizedBox(
                height: messageHeight,
                child: Center(child: Text("An error occurred")),
              );
            }

            List<String> categories = snapshot.data ?? [];
            if (categories.isEmpty) {
              return const SizedBox(
                height: messageHeight,
                child: Center(child: Text("No labels found")),
              );
            } else {
              for (var category in categories) {
                categoryFilters.putIfAbsent(category, () => true);
              }
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    height: categories.length * tileHeight,
                    child: ListView(
                      children: categories.map((String category) {
                        return CheckboxListTile(
                          title: Text(category),
                          value: categoryFilters[category],
                          activeColor: Colors.black,
                          onChanged: (bool? value) {
                            setState(() {
                              categoryFilters[category] = value!;
                            });
                            widget.onFilterChanged(categoryFilters);
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
