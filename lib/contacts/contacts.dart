// contacts.dart
import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text("Contacts", style: headingStyle(color: Colors.black)),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.grey),
          onPressed: () {},
        ),
      ],
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
            onTap: () {
              Navigator.of(context).push(_createRoute(ContactsDetailPage(id: _contacts[index]["id"])));
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
