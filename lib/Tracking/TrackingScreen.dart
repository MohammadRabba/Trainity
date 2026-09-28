import 'package:Trainity/Tracking/AddReportScreen.dart';
import 'package:Trainity/Tracking/AddTasksScreen.dart';
import 'package:Trainity/Tracking/AttendanceScreen.dart';
import 'package:Trainity/Tracking/SubmittedTasksScreen.dart';
import 'package:Trainity/Tracking/SuperisorTracking/getReportsMentor.dart';
import 'package:Trainity/Tracking/removeStudent.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  final String oppoId;

  const TrackingScreen({super.key, required this.oppoId});
  Future<List<Map<String, dynamic>>> getListOfReports() async {
    try {
      QuerySnapshot trainingSnapshot = await FirebaseFirestore.instance
          .collection('Tracking')
          .doc('reportkDetails')
          .collection('Reports')
          .where('mentorId', isEqualTo: myid)
          .get();

      List<Map<String, dynamic>> listOfReports = [];
      for (QueryDocumentSnapshot doc in trainingSnapshot.docs) {
        Map<String, dynamic> reportData = doc.data() as Map<String, dynamic>;
        listOfReports.add(reportData);
      }

      return listOfReports;
    } catch (e) {
      print('Error fetching list of reports: $e');
      return [];
    }
  }

  Future<List<String>> getListOfStudents() async {
    try {
      DocumentSnapshot trainingSnapshot = await FirebaseFirestore.instance
          .collection('Training')
          .where('oppo_id', isEqualTo: oppoId)
          .get()
          .then((value) => value.docs.first);

      List<dynamic> listOfStudents = trainingSnapshot.get('listOfStudents');

      List<String> studentDetails = [];
      for (dynamic studentId in listOfStudents) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(studentId)
            .get();

        if (userSnapshot.exists) {
          String userName = userSnapshot.get('name');
          studentDetails.add('$userName|$studentId');
        }
      }

      return studentDetails;
    } catch (e) {
      print('Error fetching list of students: $e');
      return [];
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
          'Opportunity Tracking',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildModernButton(
                icon: Icons.calendar_today,
                label: 'Take Attendance',
                onPressed: () async {
                  List<String> students = await getListOfStudents();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AttendanceScreen(
                      students: students,
                      oppoId: oppoId,
                    ),
                  ));
                },
              ),
              const SizedBox(height: 20),
              buildModernButton(
                icon: Icons.playlist_add,
                label: 'Add Tasks',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddTasksScreen(
                      students: getListOfStudents(),
                      oppoId: oppoId,
                    ),
                  ));
                },
              ),
              const SizedBox(height: 20),
              buildModernButton(
                icon: Icons.description,
                label: 'Add Report',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddReportScreen(
                      students: getListOfStudents(),
                      oppoId: oppoId,
                    ),
                  ));
                },
              ),
              const SizedBox(height: 20),
              buildModernButton(
                icon: Icons.calendar_today,
                label: 'Get Reports',
                onPressed: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReportsMentor(),
                  ));
                },
              ),
              const SizedBox(height: 20),
              buildModernButton(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Submitted Tasks',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SubmittedTasksScreen(
                      oppoId: oppoId,
                    ),
                  ));
                },
              ),
              const SizedBox(height: 20),
              buildModernButton(
                icon: Icons.calendar_today,
                label: 'Remove Student',
                onPressed: () async {
                  List<String> students = await getListOfStudents();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RemoveScreen(
                      students: students,
                      oppoId: oppoId,
                    ),
                  ));
                },
              ),
            ],
          ),
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
