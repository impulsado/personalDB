// category_personal.dart
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/detail/detail_factory.dart';
import 'package:personaldb/widgets/refresh_notes.dart';
import 'package:personaldb/widgets/notes/note_personal.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/database/database_helper_personal.dart';
import 'package:personaldb/widgets/search/search_personal.dart';

void main() {
  runApp(const MyAppPersonal());
}

class MyAppPersonal extends StatelessWidget {
  const MyAppPersonal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: CategoryPersonal(MyCategory()),
    );
  }
}

class CategoryPersonal extends StatefulWidget {
  final MyCategory myCategory;

  const CategoryPersonal(this.myCategory, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryPersonalState createState() => _CategoryPersonalState();
}

class _CategoryPersonalState extends State<CategoryPersonal> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  late AnimationController _controller;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isAscending = true;
  List<Map<String, dynamic>> _allNotes = [];

  Future<void> _refreshNotes() async {
    try {
      _allNotes = await refreshNotes(widget.myCategory.title ?? "Error");

      _applyFilters();
      _controller.reset();
      _controller.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters({Map<String, bool>? filters}) {
    if (filters == null || filters.values.every((isSelected) => isSelected)) {
      _notes = List<Map<String, dynamic>>.from(_allNotes);
    } else {
      _notes = _allNotes.where((note) {
        String category = note["category"];
        return filters[category] ?? false;
      }).toList();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshNotes();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: widget.myCategory.bgColor,
      elevation: 0,
      title: Text(widget.myCategory.title ?? "Error", style: headingStyle(color: Colors.black)),
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onTap: () {Navigator.pop(context);},
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: widget.myCategory.bgColor ?? Colors.white,
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildNoteList(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildNoteList() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
        ),
      ),
      margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBarPersonal(
              searchController: _searchController,
              focusNode: _focusNode,
              enableOrdering: true,
              loadItemsFunction: () async {
                return await PersonalDatabaseHelper().getCategories(MyApp.dbPassword!);
              },
              onOrderSelected: (String result) {
                setState(() {
                  _isAscending = !_isAscending;
                  switch (result) {
                    case "Title":
                      _notes.sort((a, b) => _isAscending ? a["title"].toString().compareTo(b["title"].toString()) : b["title"].toString().compareTo(a["title"].toString()));
                      break;
                    case "Category":
                      _notes.sort((a, b) => _isAscending ? a["category"].toString().compareTo(b["category"].toString()) : b["category"].toString().compareTo(a["category"].toString()));
                      break;
                  }
                });
              },
              onFilterChanged: (Map<String, bool> filters) {
                _applyFilters(filters: filters);
              },
            ),
          ),
          Divider(color: Colors.grey.shade300, thickness: 1.0,),
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text("No items available"))
                : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return FadeTransition(
                  opacity: _controller.drive(
                      Tween<double>(begin: 0.0, end: 1.0)
                          .chain(CurveTween(curve: Interval((index / _notes.length), 1, curve: Curves.easeOut)))
                  ),
                  child: _note(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _note(int index) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => DetailPageFactory.getDetailPage(widget.myCategory, id: _notes[index]['id']),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
        if (result == "refresh") {
          _refreshNotes();
        }
      },
      child: NotePersonal(
        backgroundColor: Colors.grey.shade50,
        note: _notes[index],
        onDelete: () {
          _refreshNotes();
        },
        categoryName: widget.myCategory.title ?? "Error",
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return MyButton(
      label: "+ Add Note",
      bgColor: widget.myCategory.bgColor ?? Colors.black,
      iconColor: widget.myCategory.iconColor ?? Colors.white,
      onTap: () async {
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => DetailPageFactory.getDetailPage(widget.myCategory),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
        if (result == "refresh") {
          _refreshNotes();
        }
      },
    );
  }
}