// category_others.dart
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/detail/detail_factory.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/widgets/notes/note_others.dart';


void main() {
  runApp(const MyAppOthers());
}

class MyAppOthers extends StatelessWidget {
  const MyAppOthers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: CategoryOthers(MyCategory()),
    );
  }
}

class CategoryOthers extends StatefulWidget {
  final MyCategory myCategory;

  const CategoryOthers(this.myCategory);

  @override
  _CategoryOthersState createState() => _CategoryOthersState();
}

class _CategoryOthersState extends State<CategoryOthers> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  Future<void> _refreshNotes() async {
    try {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      final data = await dbHelper.getItems(MyApp.dbPassword!);
      if (data.isEmpty) {
        print("No items found in the database");
      }
      setState(() {
        _notes = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error occurred while refreshing notes: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.myCategory.bgColor,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildNoteList(),
      floatingActionButton: _buildFloatingActionButton(),
    );
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

  Widget _buildNoteList() {
    if (_notes.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        child: const Center(
          child: Text("No items available"),
        ),
      );
    } else {
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
                  MaterialPageRoute(builder: (context) => DetailPageFactory.getDetailPage(widget.myCategory, id: _notes[index]['id'])),
                );
                if (action == "refresh") {
                  _refreshNotes();
                }
              },
              child: NoteOthers(
                backgroundColor: Colors.grey.shade50,
                note: _notes[index],
                onDelete: () {
                  _refreshNotes();
                },
                categoryName: widget.myCategory.title ?? "Error",
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildFloatingActionButton() {
    return MyButton(
      label: "+ Add Note",
      bgColor: widget.myCategory.bgColor ?? Colors.black,
      iconColor: widget.myCategory.iconColor ?? Colors.white,
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPageFactory.getDetailPage(widget.myCategory),),);
        if (result == "refresh") {
          _refreshNotes();
        }
      },
    );
  }
}
