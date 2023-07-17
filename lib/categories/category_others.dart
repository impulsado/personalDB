import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/models/categories.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/detail/detail_factory.dart';
import 'package:personaldb/main.dart';

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

  void _refreshNotes() async {
    try {
      final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
      final data = await dbHelper.getItems(MyApp.dbPassword!);
      setState(() {
        if (data.isEmpty) {
          print("No items found in the database");
        } else {
          _notes = data;
        }
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
      title: Text(widget.myCategory.title ?? "Error", style: const TextStyle(color: Colors.black),),
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
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 50.0), // Aquí cambiamos el padding por un margin
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Hace que la columna se ajuste a su contenido.
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
                          _notes[index]["description"] ?? "",
                          maxLines: 5, // Limita el número de líneas a 5.
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5.0),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () async {
                          final dbHelper = DatabaseHelperFactory.getDatabaseHelper(widget.myCategory.title ?? "Error");
                          await dbHelper.deleteItem(_notes[index]['id'], MyApp.dbPassword!);
                          await Future.delayed(const Duration(milliseconds: 50));
                          _refreshNotes();
                        },
                      ),
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
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPageFactory.getDetailPage(widget.myCategory),),);
        if (result == "refresh") {
          _refreshNotes();
        }
      },
    );
  }
}
