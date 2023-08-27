// contacts.dart
import 'package:flutter/material.dart';
import 'package:personaldb/database/database_helper_contacts.dart';
import 'package:personaldb/widgets/refresh_notes.dart';
import 'package:personaldb/widgets/notes/note_contacts.dart';
import 'package:personaldb/detail/detail_contacts.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/contacts/import_contacts.dart';
import 'package:personaldb/widgets/search/search_contacts.dart';
import 'package:personaldb/widgets/button.dart';

class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _allContacts = [];
  bool _isLoading = true;
  bool _isAscending = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Future<void> _refreshContacts() async {
    try {
      _contacts = await refreshNotes("Contacts");
      _allContacts = List<Map<String, dynamic>>.from(_contacts);

      _applyFilters();

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters({Map<String, bool>? filters}) {
    _contacts = _applySearch(_searchController.text);

    if (!(filters == null || filters.values.every((isSelected) => isSelected))) {
      _contacts = _contacts.where((contact) {
        String label = contact["label"];
        return filters[label] ?? false;
      }).toList();
    }

    setState(() {
      _isLoading = false;
    });
  }


  List<Map<String, dynamic>> _applySearch(String searchText) {
    if (searchText.isEmpty) {
      return List<Map<String, dynamic>>.from(_allContacts);
    } else {
      return _allContacts.where((contact) {
        return contact.values.any((value) => value.toString().toLowerCase().contains(searchText.toLowerCase()));
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshContacts();

    _searchController.addListener(() {
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _remindMeToDays(String remindMe) {
    if (remindMe == "Do not remind me" || remindMe == "No Remind Me defined") {
      return -1;
    }

    var split = remindMe.split(' ');
    var value = int.parse(split[0]);
    var unit = split[1];

    if (unit.startsWith("week")) {
      return value * 7;
    } else if (unit.startsWith("month")) {
      return value * 30;
    }

    return 0;
  }

  PreferredSizeWidget _buildAppBar() {
    return SearchBarContacts(
      searchController: _searchController,
      focusNode: _searchFocusNode,
      enableOrdering: true,
      onOrderSelected: (String result) {
        setState(() {
          _isAscending = !_isAscending;
          switch (result) {
            case "Name":
              _contacts.sort((a, b) => _isAscending ? a["name"].toString().compareTo(b["name"].toString()) : b["name"].toString().compareTo(a["name"].toString()));
              break;
            case "Label":
              _contacts.sort((a, b) => _isAscending ? a["label"].toString().compareTo(b["label"].toString()) : b["label"].toString().compareTo(a["label"].toString()));
              break;
            case "Remind Me":
              _contacts.sort((a, b) => _isAscending ? _remindMeToDays(a["remindMe"]).compareTo(_remindMeToDays(b["remindMe"])) : _remindMeToDays(b["remindMe"]).compareTo(_remindMeToDays(a["remindMe"])));
              break;
          }
        });
      },
      loadItemsFunction: () async {
        return await ContactsDatabaseHelper().getLabels(MyApp.dbPassword!);
      },
      onFilterChanged: (Map<String, bool> filters) {
        // handle the filter changes
        _applyFilters(filters: filters);
      },
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContactList() {
    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "No contacts available",
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            if (_allContacts.isEmpty) ...[
              const SizedBox(height: 16.0),
              const Text(
                "Click 'Import' to import local contacts or Create them manually.",
                style: TextStyle(fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black, side: const BorderSide(color: Colors.black),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    _createRoute(ImportContactsWidget(password: MyApp.dbPassword!)),
                  );
                  if (result == "refresh") {
                    _refreshContacts();
                  }
                },
                child: const Text("Import"),
              ),
            ],
          ],
        ),
      );
    } else {
      return GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: Colors.black,
        child: ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  _createRoute(ContactsDetailPage(id: _contacts[index]["id"])),
                );
                if (result == "refresh") {
                  _refreshContacts();
                }
              },
              child: NoteContacts(
                backgroundColor: Colors.white,
                note: _contacts[index],
                onDelete: () {
                  _refreshContacts();
                },
                categoryName: "Contacts",
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildFloatingActionButton() {
    return MyButton(
      icon: Icons.person_add,
      bgColor: Colors.black,
      iconColor: Colors.white,
      onTap: () async {
        final result = await Navigator.push(
          context,
          _createRoute(const ContactsDetailPage()),
        );
        if (result == "refresh") {
          _refreshContacts();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildContactList(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}