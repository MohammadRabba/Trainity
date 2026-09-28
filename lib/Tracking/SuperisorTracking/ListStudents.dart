import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/SuperisorTracking/TrackStudentScreen.dart';

class ListStudents extends StatelessWidget {
  const ListStudents({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Students List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getStudentsData(),
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
                  onTap: () async {
                    Map<String, dynamic> studentDetails =
                        await _getStudentDetails(studentId);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                              '${studentDetails['name']} : ${studentDetails['id']}'),
                          content: Text(
                              'Opportunity Name :${studentDetails['oppoName']} ; Company Name :${studentDetails['compName']} , Email: ${studentDetails['compEmail']}'),
                        );
                      },
                    );
                  },
                  title: Text(studentName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
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

  Future<List<String>> getStudentOppo(String id) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Training')
          .where('listOfStudents', arrayContains: id)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? userData =
            userSnapshot.docs.first.data() as Map<String, dynamic>?;

        if (userData != null) {
          String oppoName = userData['name'] ?? '';
          String companyId = userData['company_id'] ?? '';

          List<String> oppoDetails = [oppoName, companyId];
          return oppoDetails;
        }
      } else {
        print('No document with student ID $id found in Training collection');
        return [];
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
    return [];
  }

  Future<List<String>> getCompanyDetails(String id) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(id).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          String name = userData['name'] ?? '';
          String email = userData['email'] ?? '';

          List<String> studentData = [
            name,
            email,
          ];

          return studentData;
        }
      } else {
        print('Document with ID $id does not exist');
        return [];
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> _getStudentDetails(String id) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(id).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          String name = userData['name'] ?? '';
          String email = userData['email'] ?? '';
          String studentId = email.split('@').first;
          List<String> oppoName = await getStudentOppo(id);
          List<String> compDetails = await getCompanyDetails(oppoName[1]);

          Map<String, dynamic> studentData = {
            'name': name,
            'email': email,
            'id': studentId,
            'oppoName': oppoName[0],
            'compName': compDetails[0],
            'compEmail': compDetails[1],
          };

          return studentData;
        }
      } else {
        print('Document with ID $id does not exist');
        return {};
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> _getStudentsData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('type', isEqualTo: "0")
          .where('status', isEqualTo: '3')
          .get();

      if (userSnapshot.docs.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> studentData = [];

      for (var doc in userSnapshot.docs) {
        String studentId = doc.id;
        String studentName = doc.get('name');
        studentData.add({'id': studentId, 'name': studentName});
      }

      return studentData;
    } catch (e) {
      print('Error fetching students data: $e');
      return [];
    }
  }
}
