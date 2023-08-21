import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:personaldb/database/database_helper_checklist_items.dart';
import 'package:personaldb/detail/detail_checklist_items.dart';

class CheckListWidget extends StatefulWidget {
  final int? checkListId;
  final String password;

  const CheckListWidget({Key? key, required this.checkListId, required this.password}) : super(key: key);

  @override
  _CheckListWidgetState createState() => _CheckListWidgetState();
}

class _CheckListWidgetState extends State<CheckListWidget> {
  late List<Map<String, dynamic>> tasks = [];
  final dbHelper = CheckListItemsDatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.checkListId != null && widget.checkListId != 0) {
      _loadTasks();
    }
  }

  _loadTasks() async {
    tasks = await dbHelper.getItemsByChecklistId(widget.checkListId!, widget.password);
    setState(() {});
  }

  _toggleTaskCompletion(int taskId, bool isCompleted) async {
    await dbHelper.updateItem(taskId, {"isCompleted": isCompleted ? 1 : 0}, widget.password);
    _loadTasks();
  }

  _navigateToDetail(int? id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckListItemsDetailPage(id: id, checklistId: widget.checkListId!),
      ),
    ).then((value) {
      if (value == "refresh") {
        _loadTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Items", style: subHeadingStyle(color: Colors.black)),
        ),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              if (widget.checkListId == 0)
                const Center(child: Text("Create the Check List before adding items.", style: TextStyle(color: Colors.grey)))
              else if (tasks.isEmpty)
                const Center(child: Text("No items"))
              else
                Scrollbar(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isCompleted = task["isCompleted"] == 1;

                      return ListTile(
                        leading: Checkbox(
                          value: isCompleted,
                          onChanged: (value) {
                            if (value != null) {
                              _toggleTaskCompletion(task["id"], value);
                            }
                          },
                        ),
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: task["description"] != null && task["description"] != ""
                            ? Text(task["description"])
                            : null,
                        onTap: () => _navigateToDetail(task["id"]),
                      );
                    },
                  ),
                ),
              if (widget.checkListId != 0)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.black,
                      onPressed: () => _navigateToDetail(null),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}