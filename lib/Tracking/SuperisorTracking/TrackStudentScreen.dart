import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/SuperisorTracking/Attendance.dart';
import 'package:Trainity/Tracking/SuperisorTracking/Reports.dart';
import 'package:Trainity/Tracking/SuperisorTracking/Tasks.dart';
import 'package:Trainity/Tracking/SuperisorTracking/genrateReport.dart';

class TrackStudentScreen extends StatelessWidget {
  final String studentId;

  const TrackStudentScreen({super.key, required this.studentId});

  Future<Map<String, dynamic>> getListOfStudents(String docId) async {
    try {
      Map<String, dynamic> studentDetails = {};
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(docId).get();

      if (userSnapshot.exists) {
        String userName = userSnapshot.get('name');
        studentDetails['name'] = userName;
        studentDetails['id'] = studentId;
      }

      return studentDetails;
    } catch (e) {
      print('Error fetching list of students: $e');
      return {};
    }
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
          'Tracking Students',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildModernButton(
              icon: Icons.calendar_today,
              label: 'View Attendance',
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Attendance(
                    studentId: studentId,
                  ),
                ));
              },
            ),
            const SizedBox(height: 20),
            buildModernButton(
              icon: Icons.playlist_add,
              label: 'view Tasks',
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StudentTasks(
                    studentId: studentId,
                  ),
                ));
              },
            ),
            const SizedBox(height: 20),
            buildModernButton(
              icon: Icons.description,
              label: 'View Reports',
              onPressed: () async {
                Map<String, dynamic> student =
                    await getListOfStudents(studentId);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Reports(
                    studentId: studentId,
                    studentName: student['name'],
                  ),
                ));
              },
            ),
            const SizedBox(height: 20),
            buildModernButton(
              icon: Icons.description,
              label: 'Generate Reports',
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PdfGeneratorPage(
                    students: studentId,
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildModernButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: const LinearGradient(
            colors: [Colors.indigo, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
