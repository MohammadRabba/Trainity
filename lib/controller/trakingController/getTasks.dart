import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetTasksController {
  final StreamController<List<Map<String, dynamic>>> _taskStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> getTasksStream(String st) {
    _fetchTasks(st);
    return _taskStreamController.stream;
  }

  void _fetchTasks(String stId) async {
    FirebaseFirestore.instance
        .collection('Tracking')
        .doc('taskDetails')
        .collection('Tasks')
        .where('students', arrayContains: stId)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) async {
      List<Map<String, dynamic>> orders = [];

      var tasksFetch = querySnapshot.docs.map((doc) async {
        var taskData = {
          'mentorId': doc['mentorId'],
          "id": doc.id,
          "fileName": doc['fileName'],
          "fileURL": doc['fileURL'],
          "submissionDeadline": doc['submissionDeadline'],
          "description": doc['description'],
          'from': doc['from'],
          'status': 'No Status'
        };

        var statusSnapshot = await FirebaseFirestore.instance
            .collection('Tracking')
            .doc('taskDetails')
            .collection('TasksResults')
            .where('task_id', isEqualTo: doc.id)
            .get();

        if (statusSnapshot.docs.isNotEmpty) {
          String mark = 'No Mark Yet.';
          Map<String, dynamic> data =
              statusSnapshot.docs.first.data() as Map<String, dynamic>;

          if (data.containsKey('mark')) {
            mark = data['mark'];
          }
          taskData['mark'] = mark;
          taskData['status'] = statusSnapshot.docs.first.get('status');
        }

        return taskData;
      });

      orders = await Future.wait(tasksFetch);

      _taskStreamController.add(orders);
    });
  }

  void dispose() {
    _taskStreamController.close();
  }
}
