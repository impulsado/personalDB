/*
// topic_box.dart
import 'package:flutter/material.dart';
import 'package:personaldb/database/database_helper_topics.dart';
import 'package:personaldb/detail/detail_topics.dart';
import 'package:personaldb/main.dart';

class TopicBox extends StatefulWidget {
  final int contactId;
  final String title;

  const TopicBox({Key? key, required this.contactId, required this.title})
      : super(key: key);

  @override
  _TopicBoxState createState() => _TopicBoxState();
}

class _TopicBoxState extends State<TopicBox> {
  bool isLoading = false;
  late List<Map<String, dynamic>> topics;

  @override
  void initState() {
    super.initState();
    fetchTopics();
  }

  fetchTopics() async {
    if (widget.contactId == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    if(MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    topics = await TopicsDatabaseHelper().getTopicsByContactId(widget.contactId, MyApp.dbPassword!);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: widget.contactId == null
            ? Text('Crea primero el contacto para crear los topicos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black))
            : isLoading
            ? CircularProgressIndicator()
            : ListView.builder(
          itemCount: topics.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(topics[index]["title"],
                  style: TextStyle(color: Colors.black)),
              subtitle: Text(topics[index]["description"],
                  style: TextStyle(color: Colors.black)),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TopicDetailPage(id: topics[index]["id"]),
                  ),
                );
                if (result == "refresh") {
                  fetchTopics();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
*/