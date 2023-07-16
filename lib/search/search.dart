import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //title: Text('Search', style: headingStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              /*
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
               */
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.lock,
              color: Colors.grey,
              size: 100.0,
            ),
            SizedBox(height: 10,),
            Text(
              'COMING SOON!',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}