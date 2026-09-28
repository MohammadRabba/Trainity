import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetReportsController {
  final StreamController<List<Map<String, dynamic>>> _reportStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> getReportStream(String id) {
    _fetchReport(id);
    return _reportStreamController.stream;
  }

  Stream<List<Map<String, dynamic>>> getReportMentorStream(String id) {
    _fetchReportMentor(id);
    return _reportStreamController.stream;
  }

  void _fetchReport(String id) {
    FirebaseFirestore.instance
        .collection('Tracking')
        .doc('reportkDetails')
        .collection('Reports')
        .where('student', arrayContains: id)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> orders = [];

      for (var doc in querySnapshot.docs) {
        var comment = doc['comment'] ?? 'No Comment';
        var supercomment = doc['Supercomment'] ?? 'No Comment';
        var mentorComment = doc['mentor_comment'] ?? 'No Comment';

        orders.add({
          "id": doc.id,
          "fileName": doc['fileName'],
          "fileURL": doc['fileURL'],
          "description": doc['description'],
          "student": doc['student'],
          "comment": comment,
          "mentor_comment": mentorComment,
          'Supercomment': supercomment,
        });
      }
      _reportStreamController.add(orders);
    });
  }

  void _fetchReportMentor(String id) {
    FirebaseFirestore.instance
        .collection('Tracking')
        .doc('reportkDetails')
        .collection('Reports')
        .where('mentorId', isEqualTo: id)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> orders = [];

      for (var doc in querySnapshot.docs) {
        var comment = doc['comment'] ?? 'No Comment';
        var supercomment = doc['Supercomment'] ?? '';
        var mentorComment = doc['mentor_comment'] ?? '';

        orders.add({
          "id": doc.id,
          "fileName": doc['fileName'],
          "fileURL": doc['fileURL'],
          "description": doc['description'],
          "student": doc['student'],
          "comment": comment,
          "mentor_comment": mentorComment,
          'Supercomment': supercomment,
        });
      }
      _reportStreamController.add(orders);
    });
  }

  void dispose() {
    _reportStreamController.close();
  }
}
