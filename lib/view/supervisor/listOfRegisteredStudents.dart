import 'dart:async';

import 'package:Trainity/model/StudentModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class studentListScreen extends StatelessWidget {
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
          'Students',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<List<StudentModel>>(
        stream: fetchStudentsWithTypeOne(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No students found'));
          } else {
            List<StudentModel> students = snapshot.data!;
            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                StudentModel student = students[index];
                return ListTile(
                  leading: (student.photo != null && student.photo.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(student.photo))
                      : CircleAvatar(
                          backgroundImage: AssetImage('assets/default.png')),
                  title: Text(student.name ?? 'No Name'),
                  subtitle: Text(student.email ?? 'No Email'),
                  onTap: () => showStudentDetails(context, student),
                );
              },
            );
          }
        },
      ),
    );
  }

  String statusBasedOnName(String st) {
    if (st == '0') {
      //sent
      return 'Not Register';
    } else if (st == '1') {
      //updated
      return 'Waiting Your Approvment';
    } else if (st == '2') {
      //late
      return 'Waiting Company Approvment';
    } else if (st == '3') {
      //marked
      return 'Registered';
    } else {
      return '';
    }
  }

  void showStudentDetails(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(student.name ?? 'No Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Student ID: ${student.studentId}'),
                Text('Email: ${student.email}'),
                Text('Phone: ${student.phone}'),
                Text('GPA: ${student.gpa}'),
                Text('Algorithm: ${student.algorithm}'),
                Text('Database: ${student.database}'),
                Text('Data Structure: ${student.datastructure}'),
                Text('Status: ${statusBasedOnName(student.status)}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Stream<List<StudentModel>> fetchStudentsWithTypeOne() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('type', isEqualTo: '0')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StudentModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
