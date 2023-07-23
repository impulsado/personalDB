// search.dart
import 'package:flutter/material.dart';
import 'package:personaldb/search/search_results.dart';

class Search extends StatefulWidget {
  final String password;

  const Search({super.key, required this.password});

  @override
  // ignore: library_private_types_in_public_api
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  String _currentSearch = "";

  void _onSearchChanged() {
    if (_searchController.text.length > 1) {
      setState(() {
        _currentSearch = _searchController.text;
      });
    } else if (_currentSearch.isNotEmpty) {
      setState(() {
        _currentSearch = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          onPressed: null,
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: "Search...",
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                _searchController.clear();
              },
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
      body: SearchResults(query: _currentSearch, password: widget.password),
    );
  }
}