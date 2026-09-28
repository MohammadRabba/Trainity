import 'dart:io';
import 'dart:typed_data';

import 'package:Trainity/notification/createnote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

class PdfGeneratorPage extends StatefulWidget {
  String? students;
  PdfGeneratorPage({Key? key, this.students}) : super(key: key);

  @override
  _PdfGeneratorPageState createState() => _PdfGeneratorPageState();
}

class _PdfGeneratorPageState extends State<PdfGeneratorPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> st = [];
  int present = 0;
  int total = 0;
  int marIs = 0;
  int fullAttendance = 0;
  int ubsAttendance = 0;
  List<Map<String, dynamic>> tasks = [];
  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {}

  @override
  void dispose() {
    super.dispose();
    ubsAttendance = 0;
    present = 0;
    fullAttendance = 0;
  }

  String statusBasedOnName(String st) {
    if (st == '1') {
      //sent
      return 'sent';
    } else if (st == '2') {
      //updated
      return 'updated';
    } else if (st == '3') {
      //late
      return 'Late';
    } else if (st == '4') {
      //marked
      return 'Marked';
    }
    return '';
  }

  Future<void> createPdfAndUpload(String studentId) async {
    final pdf = pw.Document();
    final path = (await getApplicationDocumentsDirectory()).path;

    final file = File("$path/${DateTime.now().millisecondsSinceEpoch}_PDF.pdf");

    final studentData =
        await _firestore.collection('user').doc(studentId).get();
    final studentName = studentData.data()?['name'] ?? 'Unknown';
    final email = studentData.data()?['email'] ?? 'Unknown';
    final id = email.split('@').first;
    await _fetchTasksAttendence();

    tasks = await fetchTasks(widget.students ?? '');
    pdf.addPage(pw.MultiPage(
      build: (context) => [
        _buildHeader(studentName, id, email),
        _buildAttendanceSection(),
        _buildTasksTable(tasks),
      ],
    ));

    Uint8List bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/${studentId}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report downloaded to $filePath'),
        backgroundColor: Colors.green,
      ),
    );
    createnewnote('Downloaded Complete', ' Report downloaded to $filePath');
    await uploadFile(file);
  }

  Future<bool> checkmarks(String taskId) async {
    try {
      QuerySnapshot q = await FirebaseFirestore.instance
          .collection('Tracking')
          .doc('taskDetails')
          .collection('TasksResults')
          .where('student_id', isEqualTo: widget.students ?? '')
          .where('task_id', isEqualTo: taskId)
          .get();

      if (q.docs.isNotEmpty) {
        var data = q.docs.first.data();
        if (data is Map<String, dynamic>) {
          var mar = data['mark'];
          if (mar != null) {
            marIs = int.parse(mar);
          }

          return mar != null;
        }
      }
    } catch (e) {
      print('Error checking marks: $e');
      return false;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> fetchTasks(String studentId) async {
    List<Map<String, dynamic>> tasksStudent = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Tracking')
        .doc('taskDetails')
        .collection('TasksResults')
        .where('student_id', isEqualTo: studentId)
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> taskData = {
        "id": doc.id,
        "fileName": doc['fileName'],
        "fileURL": doc['fileURL'],
        "submissionDeadline": doc['submissionDeadline'],
        "description": doc['description'],
        'from': doc['from'],
        'status': doc['status']
      };

      if (doc.data() is Map<String, dynamic> &&
          (doc.data() as Map<String, dynamic>).containsKey('mark')) {
        String mark = doc['mark'] ?? '';
        taskData['mark'] = mark;
      }

      tasksStudent.add(taskData);
    }

    return tasksStudent;
  }

  pw.Widget _buildHeader(String studentName, String id, String email) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Student Report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Name: $studentName', style: pw.TextStyle(fontSize: 18)),
        pw.SizedBox(height: 10),
        pw.Text('Student Id: $id', style: pw.TextStyle(fontSize: 18)),
        pw.SizedBox(height: 10),
        pw.Text('Email: $email', style: pw.TextStyle(fontSize: 18)),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildTasksTable(List<Map<String, dynamic>> tasksList) {
    const tableHeaders = [
      'Task Name',
      'URL',
      'Description',
      'Mark',
      'From',
      'DeadLine Date',
      'Status',
    ];
    List<List> data = tasksList.map((task) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          task['submissionDeadline'].seconds * 1000 +
              task['submissionDeadline'].nanoseconds ~/ 1000000);

      String formattedDateTime = dateTime.toString();

      return [
        task['fileName'] ?? 'No File',
        task['fileURL'] ?? '',
        task['description'] ?? '',
        task['mark'],
        task['from'] ?? '',
        formattedDateTime,
        statusBasedOnName(task['status']),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(2),
        color: PdfColors.grey300,
      ),
      headerHeight: 25,
      cellHeight: 40,
      headerStyle: pw.TextStyle(
        color: PdfColors.black,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: PdfColors.black,
        fontSize: 10,
      ),
      headers: tableHeaders,
      data: data,
    );
  }

  pw.Widget _buildAttendanceSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Student Report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Present Days: $present', style: pw.TextStyle(fontSize: 18)),
        pw.SizedBox(height: 10),
        pw.Text('Absent Days: ${ubsAttendance}',
            style: pw.TextStyle(fontSize: 18)),
        pw.SizedBox(height: 10),
        pw.Text('Total Days: $fullAttendance',
            style: pw.TextStyle(fontSize: 18)),
        pw.Divider(),
      ],
    );
  }

  Future<String> getoppoId() async {
    try {
      String oppo_id = '';
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('Training')
          .where('listOfStudents', arrayContains: widget.students)
          .get();

      if (query.docs.isNotEmpty) {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;

        oppo_id = data['oppo_id'] as String;
      }
      return oppo_id;
    } catch (e) {
      print('Error getting oppo_id: $e');
      return '';
    }
  }

  Future<void> _fetchTasksAttendence() async {
    String oppo = await getoppoId();
    FirebaseFirestore.instance
        .collection('Tracking')
        .doc('attendanceDetails')
        .collection(oppo)
        .where(widget.students ?? '')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          fullAttendance = fullAttendance + 1;
          if (doc[widget.students ?? ''] == true) {
            present = present + 1;
          } else {
            ubsAttendance = ubsAttendance + 1;
          }
        });
      }
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }

  Future<void> uploadFile(File file) async {
    try {
      String filePath =
          'PDFs/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      TaskSnapshot taskSnapshot = await _storage.ref(filePath).putFile(file);
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Report Generated Successfully"),
          backgroundColor: Colors.green,
        ),
      );
      _launchURL(downloadUrl);
    } catch (e) {
      print(e.toString());
    }
  }

  String _selectedStudentName = '';
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
          'Generate Report',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Upload Confirmation'),
                  content: Text('Are you sure you want to Generate Report ?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('generate'),
                      onPressed: () {
                        createPdfAndUpload(widget.students ?? '');

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
          icon: Icon(Icons.download),
          label: Text('Generate Report'),
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 63, 71, 212),
            onPrimary: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
    );
  }
}
