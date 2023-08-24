// topics_list_view.dart
import 'package:flutter/material.dart';
import 'package:personaldb/database/database_helper_factory.dart';
import 'package:personaldb/database/database_helper_topics.dart';
import 'package:personaldb/detail/detail_topics.dart';
import 'package:personaldb/main.dart';
import 'package:personaldb/constants/theme.dart';

class TopicsListView extends StatefulWidget {
  final int? contactId;

  const TopicsListView({Key? key, @required this.contactId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TopicsListViewState createState() => _TopicsListViewState();
}

class _TopicsListViewState extends State<TopicsListView> {
  late TopicsDatabaseHelper _dbHelper;
  late List<Map<String, dynamic>> _topics;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelperFactory.getDatabaseHelper("Topics") as TopicsDatabaseHelper;
    _topics = [];
    if (widget.contactId != null) _loadTopics();
  }

  _loadTopics() async {
    if (MyApp.dbPassword == null) {
      throw ArgumentError("Database password is null");
    }

    List<Map<String, dynamic>> topics =
    await _dbHelper.getTopicsByContactId(widget.contactId!, MyApp.dbPassword!);

    List<Map<String, dynamic>> topicsMutable = List.from(topics);

    topicsMutable.sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));

    setState(() {
      _topics = topicsMutable;
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
          Text("Topics", style: subHeadingStyle(color: Colors.black)),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.contactId == null ? const Center(
                child: Text(
                  "Create the contact before adding topics.",
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ) : Padding(
                padding: const EdgeInsets.only(left: 14.0, top: 16.0, bottom: 8.0),
                child: Stack(
                  children: [
                    Visibility(
                      visible: _topics.isNotEmpty,
                      replacement: const Text(
                        "Add topics here.",
                        style: TextStyle(color: Colors.grey, fontSize: 16.0),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _topics.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                visualDensity: const VisualDensity(vertical: -3),
                                contentPadding: const EdgeInsets.only(left: 0.0),
                                title: Text(
                                  _topics[index]["title"],
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                                subtitle: Text(
                                  _topics[index]["description"],
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) => TopicDetailPage(id: _topics[index]["id"], contactId: widget.contactId!),
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
                                    _loadTopics();
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
                          backgroundColor: Colors.grey,
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => TopicDetailPage(id: null, contactId: widget.contactId!),
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
                              _loadTopics();
                            }
                          },
                          child: const Icon(Icons.add, color: Colors.black,),
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
