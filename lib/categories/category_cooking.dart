import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/detail/detail_factory.dart';
import 'package:personaldb/widgets/star_rating.dart';
import 'package:personaldb/main.dart';

class DifficultyRating extends StatelessWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final double itemSize;
  final bool isReadOnly;

  DifficultyRating({
    required this.onChanged,
    this.initialValue = 0.0,
    this.itemSize = 40.0,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return index < initialValue
            ? Icon(Icons.local_fire_department, size: itemSize, color: Colors.red)
            : Icon(Icons.local_fire_department, size: itemSize, color: Colors.grey);
      }),
    );
  }
}

void main() {
  runApp(const MyAppCooking());
}

class MyAppCooking extends StatelessWidget {
  const MyAppCooking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.light,
      home: CategoryCooking(MyCategory()),
    );
  }
}

class CategoryCooking extends StatefulWidget {
  final MyCategory myCategory;

  const CategoryCooking(this.myCategory);

  @override
  _CategoryCookingState createState() => _CategoryCookingState();
}

class _CategoryCookingState extends State<CategoryCooking> {
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
        child: Center(
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
            return Stack(
              children: [
                GestureDetector(
                  onTap: () async {
                    String? action = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailPageFactory.getDetailPage(widget.myCategory, id: _notes[index]['id'])),
                    );
                    if (action == "refresh") {
                      _refreshNotes();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,  // Color del InkWell
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(right: 50.0, left: 13.0),  // Padding added here
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5.0),
                            Text(
                              _notes[index]["title"] ?? "No Title",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              _notes[index]["duration"] ?? "",
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5.0),
                            Row(
                              children: [
                                DifficultyRating(
                                  initialValue: double.parse(_notes[index]["difficulty"] ?? "0"),
                                  onChanged: (value) {},
                                  itemSize: 20,
                                  isReadOnly: true,
                                ),
                                SizedBox(width: 15),
                                StarRating(
                                  initialValue: double.parse(_notes[index]["rate"] ?? "0"),
                                  onChanged: (value) {},
                                  itemSize: 20,
                                  isReadOnly: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        _deleteNoteConfirmation(context, index);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  void _deleteNoteConfirmation(BuildContext context, int index) async {
    final confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey),),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE", style: TextStyle(color: Colors.red),),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      await dbHelper.deleteItem(_notes[index]['id'], MyApp.dbPassword!);
      await Future.delayed(const Duration(milliseconds: 250));
      await _refreshNotes();
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