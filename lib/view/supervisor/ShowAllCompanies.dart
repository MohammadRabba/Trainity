import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/SuperisorTracking/TrackStudentScreen.dart';

class ListCompanies extends StatelessWidget {
  const ListCompanies({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Companies List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getCompaniesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No students found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String studentId = snapshot.data![index]['id'];
                String studentName = snapshot.data![index]['name'];
                return ListTile(
                  title: Text(studentName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          print('Tapped studentId: $studentId for Attendance');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TrackStudentScreen(studentId: studentId),
                            ),
                          );
                        },
                        child: const Text('Track'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getCompaniesData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('type', isEqualTo: "1")
          .get();

      if (userSnapshot.docs.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> studentData = [];

      for (var doc in userSnapshot.docs) {
        String studentName = doc.get('name');
        studentData.add({'name': studentName});
      }

      return studentData;
    } catch (e) {
      print('Error fetching students data: $e');
      return [];
    }
  }
}
