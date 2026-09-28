import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class TaskResultsController {
  final StreamController<List<Map<String, dynamic>>> _taskResultsController =
      StreamController<List<Map<String, dynamic>>>();

  Stream<List<Map<String, dynamic>>> get taskResultsStream =>
      _taskResultsController.stream;

  Future<void> fetchTaskResults(String docId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> taskResultsSnapshot =
          await FirebaseFirestore.instance
              .collection('Tracking')
              .doc('taskDetails')
              .collection('TasksResults')
              .where('task_id', isEqualTo: docId)
              .get();

      List<Map<String, dynamic>> taskResults = [];

      for (var doc in taskResultsSnapshot.docs) {
        Map<String, dynamic> taskResultData = doc.data() ?? {};

        String studentId = taskResultData['student_id'];

        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('user')
                .doc(studentId)
                .get();

        if (userSnapshot.exists) {
          String studentName = userSnapshot.data()?['name'] ?? 'Unknown';
          taskResultData['submitted_by'] = 'Submitted by: $studentName';
        } else {
          taskResultData['submitted_by'] = 'Submitted by: Unknown';
        }

        taskResultData['doc_id'] = doc.id;

        taskResults.add(taskResultData);
      }

      _taskResultsController.add(taskResults);
    } catch (e) {
      print('Error fetching task results: $e');
      _taskResultsController.addError('Error fetching task results: $e');
    }
  }

  void dispose() {
    _taskResultsController.close();
  }
}
