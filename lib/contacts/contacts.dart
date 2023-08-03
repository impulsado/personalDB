// contacts.dart
import 'package:flutter/material.dart';
import 'package:personaldb/widgets/search_appbar.dart';
import 'package:personaldb/widgets/button.dart';
import 'package:personaldb/widgets/refresh_notes.dart';
import 'package:personaldb/widgets/notes/note_contacts.dart';
import 'package:personaldb/detail/detail_contacts.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/contacts/import_contacts.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  bool _isAscending = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Future<void> _refreshContacts() async {
    try {
      _contacts = await refreshNotes("Contacts");
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  int _remindMeToDays(String remindMe) {
    if (remindMe == "Do not remind me") {
      return -1;
    }

    var split = remindMe.split(' ');
    var value = int.parse(split[0]);
    var unit = split[1];

    if (unit.startsWith('week')) {
      return value * 7;
    } else if (unit.startsWith('month')) {
      return value * 30;
    }

    return 0;
  }

  PreferredSizeWidget _buildAppBar() {
    return SearchAppBar(
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
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Click 'Import' to import local contacts or Create them manually.",
              style: TextStyle(fontSize: 12.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, side: const BorderSide(
                color: Colors.black,
              ),
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
        ),
      );
    } else {
      return ListView.builder(
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
              backgroundColor: Colors.grey.shade100,
              note: _contacts[index],
              onDelete: () {
                _refreshContacts();
              },
              categoryName: "Contacts",
            ),
          );
        },
      );
    }
  }

  Widget _buildFloatingActionButton() {
    return MyButton(
      label: "+ Add Contact",
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
