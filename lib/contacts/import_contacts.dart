import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personaldb/database/database_helper_contacts.dart';
import 'package:personaldb/constants/theme.dart';

class ImportContactsWidget extends StatefulWidget {
  final String password;

  const ImportContactsWidget({Key? key, required this.password}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ImportContactsWidgetState createState() => _ImportContactsWidgetState();
}

class _ImportContactsWidgetState extends State<ImportContactsWidget> {
  final ContactsDatabaseHelper _dbHelper = ContactsDatabaseHelper();
  bool _isLoading = false;

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text("Import contacts", style: headingStyle(color: Colors.black)),
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onTap: () {Navigator.pop(context);},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Access to your contacts is required for one-time import only.\n"
                "All data is stored in an encrypted database on your device.\n\n",
                style: TextStyle(fontSize: 14.0),
                textAlign: TextAlign.center,
              ),
              const Text(
                "The application will NEVER use your contacts for any other purpose.",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              if (_isLoading)
                const CircularProgressIndicator(),
              if (!_isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      onPressed: importContacts,
                      child: const Text("Import"),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> importContacts() async {
    if (await Permission.contacts.request().isGranted) {
      setState(() {
        _isLoading = true;
      });

      Iterable<Contact> contacts = await ContactsService.getContacts();

      for (var contact in contacts) {
        String displayName = contact.displayName ?? "No name";
        String phone = (contact.phones!.isNotEmpty ? contact.phones?.first.value : null) ?? "No phone";

        Map<String, dynamic> newContact = {
          "name": displayName,
          "phone": phone,
          // Add the rest of the fields as null
        };

        await _dbHelper.createItem(newContact, widget.password);
      }

      setState(() {
        _isLoading = false;
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context, 'refresh');
    } else {
      // Handle the fact that the user did not grant permission
      //print('Permission to access contacts was denied.');
    }
  }
}
