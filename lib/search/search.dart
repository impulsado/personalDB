// search.dart
import 'package:flutter/material.dart';
import 'package:personaldb/search/search_results.dart';

class Search extends StatefulWidget {
  final String password;

  Search({required this.password});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();  // Nuevo objeto FocusNode

  String _currentSearch = '';

  void _onSearchChanged() {
    if (_searchController.text.length > 1) {
      setState(() {
        _currentSearch = _searchController.text;
      });
    } else if (_currentSearch.isNotEmpty) {
      setState(() {
        _currentSearch = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();  // Solicita enfoque después de que el marco se haya renderizado
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();  // No olvides eliminar el FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: null,
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,  // Asocia el FocusNode al TextField
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search...',
            suffixIcon: IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                _searchController.clear();
              },
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
      body: SearchResults(query: _currentSearch, password: widget.password),
    );
  }
}