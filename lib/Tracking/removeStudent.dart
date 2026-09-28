import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RemoveScreen extends StatefulWidget {
  final List<String> students;
  final String oppoId;

  const RemoveScreen({super.key, required this.students, required this.oppoId});

  @override
  _RemoveScreenState createState() => _RemoveScreenState();
}

class _RemoveScreenState extends State<RemoveScreen> {
  final UpdateStatus _updateStatus = UpdateStatus();

  @override
  void initState() {
    super.initState();
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance taken successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Remove Student',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.students.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5.0,
                    margin: const EdgeInsets.symmetric(vertical: 8),
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
                      child: ListTile(
                        title: Text(
                          widget.students[index].split('|')[0],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Remove Student'),
                                content: Text(
                                    'Are you sure you want to remove Student ?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('remove'),
                                    onPressed: () {
                                      print(widget.students[index]
                                          .split('|')
                                          .last);
                                      removeStudent(widget.students[index]
                                          .split('|')
                                          .last);
                                      _updateStatus.updateStudentStatus(
                                          "0",
                                          widget.students[index]
                                              .split('|')
                                              .last);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> removeStudent(String studentId) async {
    QuerySnapshot s = await FirebaseFirestore.instance
        .collection('Training')
        .where('oppo_id', isEqualTo: widget.oppoId)
        .get();

    if (s.docs.isNotEmpty) {
      DocumentSnapshot firstDoc = s.docs.first;

      if (firstDoc.exists) {
        List<dynamic> ls = firstDoc['listOfStudents'] ?? [];

        if (ls.contains(studentId)) {
          ls.remove(studentId);

          String docId = firstDoc.id;

          await FirebaseFirestore.instance
              .collection('Training')
              .doc(docId)
              .update({'listOfStudents': ls});
          await FirebaseFirestore.instance
              .collection('user')
              .doc(studentId)
              .update({'status': '0'});
          _showSuccessMessage();
          createnewnote('Removed Successfully', "Student Removed");
        }
      }
    }
  }
}
