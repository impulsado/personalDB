import 'package:flutter/material.dart';

class SearchBarCheckList extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool enableOrdering;
  final Function(String)? onOrderSelected;
  final void Function(Map<String, bool>) onFilterChanged;

  const SearchBarCheckList({
    Key? key,
    required this.searchController,
    required this.focusNode,
    required this.enableOrdering,
    required this.onOrderSelected,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchBarCheckListState createState() => _SearchBarCheckListState();
}

class _SearchBarCheckListState extends State<SearchBarCheckList> {

  @override
  void initState() {
    super.initState();
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
                leading: const Icon(Icons.timer_outlined),
                title: const Text("Sort by Duration"),
                onTap: () => _selectOrderOption(context, "Duration"),
              ),
              ListTile(
                leading: const Icon(Icons.euro_outlined),
                title: const Text("Sort by Price"),
                onTap: () => _selectOrderOption(context, "Price"),
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
