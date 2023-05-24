import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/detail/detail.dart';
import 'package:personaldb/database/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: CategoryList(MyCategory()),
    );
  }
}

class CategoryList extends StatefulWidget {
  final MyCategory myCategory;

  const CategoryList(this.myCategory);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  void _refreshNotes() async {
    final data = await SQLHelper.getItemsByCategory(widget.myCategory.title ?? "Error");
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildNoteList(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: widget.myCategory.bgColor,
      elevation: 0,
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onTap: () {Navigator.pop(context);},
      ),
    );
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildNoteList() {
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            String? action = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailPage(widget.myCategory, id: _notes[index]['id'])),
            );
            if (action == 'refresh') {
              _refreshNotes();
            }
          },
          onDoubleTap: () async {
            await SQLHelper.deleteItem(_notes[index]['id']);
            _refreshNotes();
          },
          child: Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,  // Color del InkWell
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey),
            ),
            child: Text(_notes[index]['title'] ?? 'No Title'),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return MyButton(
      label: "+ Add Note",
      bgColor: widget.myCategory.bgColor ?? Colors.black,
      iconColor: widget.myCategory.iconColor ?? Colors.white,
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(widget.myCategory),),);
        if (result == 'refresh') {
          _refreshNotes();
        }
      },
    );
  }
}