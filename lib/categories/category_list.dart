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
  final _scrollController = ScrollController();

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
      backgroundColor: widget.myCategory.bgColor,  // color de fondo igual al del AppBar
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: ListView.builder(
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
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              height: 90.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,  // Color del InkWell
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _notes[index]['title'] ?? 'No Title',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5.0),
                  Expanded(
                    child: Text(
                      _notes[index]['description'] ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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