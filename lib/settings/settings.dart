import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/database/database_helper.dart';

class Settings extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: headingStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onTap: () {Navigator.pop(context);},
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 50.0,
                margin: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: DatabaseHelper.exportDatabase,
                  child: const Text('Export Database'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}