// items_list_view.dart
import 'package:flutter/material.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_checklist_items.dart';
import 'package:personaldb/detail/detail_checklist_items.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/constants/theme.dart';

class ItemsListView extends StatefulWidget {
  final int? checklistId;

  const ItemsListView({Key? key, @required this.checklistId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ItemsListViewState createState() => _ItemsListViewState();
}

class _ItemsListViewState extends State<ItemsListView> {
  late CheckListItemsDatabaseHelper _dbHelper;
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelperFactory.getDatabaseHelper("Check List Items") as CheckListItemsDatabaseHelper;
    _items = [];
    if (widget.checklistId != null) _loadItems();
  }

  _loadItems() async {
    if (MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    List<Map<String, dynamic>> items =
    await _dbHelper.getItemsByChecklistId(widget.checklistId!, MyApp.dbPassword!);

    List<Map<String, dynamic>> itemsMutable = List.from(items);

    itemsMutable.sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));

    setState(() {
      _items = itemsMutable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Items", style: subHeadingStyle(color: Colors.black)),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.checklistId == null ? const Center(
                child: Text(
                  "Create the Check List before adding items.",
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ) : Padding(
                padding: const EdgeInsets.only(left: 14.0, top: 16.0, bottom: 8.0),
                child: Stack(
                  children: [
                    Visibility(
                      visible: _items.isNotEmpty,
                      replacement: const Text(
                        "Add items here.",
                        style: TextStyle(color: Colors.grey, fontSize: 16.0),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                visualDensity: const VisualDensity(vertical: -3),
                                contentPadding: const EdgeInsets.only(left: 0.0),
                                title: Text(
                                  _items[index]["title"],
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                                subtitle: Text(
                                  _items[index]["description"],
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) => CheckListItemsDetailPage(id: _items[index]["id"], checklistId: widget.checklistId!),
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
                                    _loadItems();
                                  }
                                },
                              ),
                              Divider(color: Colors.grey.shade600),
                            ],
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                        child: FloatingActionButton.small(
                          backgroundColor: Colors.black,
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => CheckListItemsDetailPage(id: null, checklistId: widget.checklistId!),
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
                              _loadItems();
                            }
                          },
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
