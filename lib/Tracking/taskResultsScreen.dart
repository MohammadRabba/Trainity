import 'dart:async';

import 'package:Trainity/Tracking/EvaluateTasks.dart';
import 'package:Trainity/controller/trakingController/taskController.dart';
import 'package:flutter/material.dart';

class TaskResultsScreen extends StatefulWidget {
  final String docId;

  const TaskResultsScreen({Key? key, required this.docId}) : super(key: key);

  @override
  _TaskResultsScreenState createState() => _TaskResultsScreenState();
}

class _TaskResultsScreenState extends State<TaskResultsScreen> {
  late TaskResultsController _TaskResultsController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    _TaskResultsController = TaskResultsController();
    await _TaskResultsController.fetchTaskResults(widget.docId);
    setState(() {
      isLoading = true;
    });
  }

  @override
  void dispose() {
    _TaskResultsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Task Results',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? StreamBuilder<List<Map<String, dynamic>>>(
              stream: _TaskResultsController.taskResultsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    (snapshot.data as List).isEmpty) {
                  return const Center(
                      child: Text('No task results available.'));
                } else {
                  List<Map<String, dynamic>> taskResults =
                      snapshot.data as List<Map<String, dynamic>>;

                  return ListView.builder(
                    itemCount: taskResults.length,
                    itemBuilder: (context, index) {
                      final taskResult = taskResults[index];

                      return Card(
                        color: Colors.indigo,
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            taskResult['fileName'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 246, 246, 246),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Column(
                            children: [
                              Text(
                                " Mark:",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(159, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                taskResult['mark'] ?? 'No Mark Yet',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Card(
                            elevation: 3,
                            margin: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                taskResult['submitted_by'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EvaluateScreen(taskDetails: taskResult),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
