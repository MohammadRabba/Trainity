import 'dart:io';
import 'dart:typed_data';

import 'package:Trainity/Tracking/SuperisorTracking/TrackStudentScreen.dart';
import 'package:Trainity/Tracking/showTasksList.dart';
import 'package:Trainity/Tracking/studentTrackPage.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/company/homepagecompany.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SendTask extends StatefulWidget {
  final Map<String, dynamic>? task;

  const SendTask({super.key, this.task});

  @override
  _SendTaskState createState() => _SendTaskState();
}

class _SendTaskState extends State<SendTask> {
  String _fileName = '';
  String _fileURL = '';
  String taskStatus = "0";
  bool mark = false;
  int marksIs = 0;
  double _uploadProgress = 0.0;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }

  @override
  void initState() {
    super.initState();
    initializeMark();
  }

  Future<void> initializeMark() async {
    bool markValue = await checkmarks();
    setState(() {
      mark = markValue;
    });
  }

  Future<void> downloadTaks() async {
    try {
      Reference storageReference =
          _storage.ref('files/${widget.task!['fileName']}');
      Uint8List? fileBytes = await storageReference.getData();

      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/${widget.task!['fileName']}';
      String url = await storageReference.getDownloadURL();
      _launchURL(url);
      File file = File(filePath);
      await file.writeAsBytes(fileBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task downloaded to $filePath'),
          backgroundColor: Colors.green,
        ),
      );
      createnewnote('Downloaded Complete', ' CV downloaded to $filePath');
    } catch (e) {
      print('Error downloading assignment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error downloading assignment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> checkmarks() async {
    try {
      QuerySnapshot q = await FirebaseFirestore.instance
          .collection('Tracking')
          .doc('taskDetails')
          .collection('TasksResults')
          .where('student_id', isEqualTo: myid)
          .where('task_id', isEqualTo: widget.task!['id'])
          .get();

      if (q.docs.isNotEmpty) {
        var data = q.docs.first.data();
        if (data is Map<String, dynamic>) {
          var mar = data['mark'];
          if (mar != null) {
            marksIs = int.parse(mar);
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

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && mounted) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      Reference reference = FirebaseStorage.instance
          .ref()
          .child('Tasks/${widget.task!['id']}')
          .child(fileName);
      UploadTask uploadTask = reference.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      String downloadURL = await snapshot.ref.getDownloadURL();

      if (mounted) {
        setState(() {
          _fileName = fileName;
          _fileURL = downloadURL;
        });
      }
    }
  }

  Future<void> _saveTask(BuildContext context) async {
    try {
      QuerySnapshot q = await FirebaseFirestore.instance
          .collection('Tracking')
          .doc('taskDetails')
          .collection('TasksResults')
          .where('student_id', isEqualTo: myid)
          .where('task_id', isEqualTo: widget.task!['id'])
          .get();

      if (q.docs.isNotEmpty) {
        if (getColorBasedOnDeadline(widget.task!['submissionDeadline']) ==
            Colors.red) {
          taskStatus = '3';
        } else {
          taskStatus = '2';
        }
        DocumentSnapshot doc = q.docs.first;
        await doc.reference.update({
          'student_id': myid,
          'description': widget.task!['description'],
          'submissionDeadline': DateTime.now(),
          'task_id': widget.task!['id'],
          'fileName': _fileName,
          'fileURL': _fileURL,
          'status': taskStatus,
          'from': widget.task!['from'],
        });
        String token = await noteconp.getUserToken(widget.task?['mentorId']);
        noteconp.sendNote(token, "You Have New Task Submitted",
            "Your Have New Task has Updates", 'New Task');
        noteconp.addNote(
            widget.task?['mentorId'],
            "You Have New Task Posted Submetted",
            "Your Have New Task has Updates",
            'New Task');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Task Sent Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return StudentHomePage();
            },
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('Tracking')
            .doc('taskDetails')
            .collection('TasksResults')
            .add({
          'student_id': myid,
          'description': widget.task!['description'],
          'submissionDeadline': DateTime.now(),
          'task_id': widget.task!['id'],
          'fileName': _fileName,
          'fileURL': _fileURL,
          'status': taskStatus,
          'from': widget.task!['from'],
        });
        String token = await noteconp.getUserToken(widget.task?['mentorId']);
        noteconp.sendNote(token, "You Have New Task Submetted",
            "You Have New Task has Sent", 'New Task');
        noteconp.addNote(
            widget.task?['mentorId'],
            "You Have New Task Posted Submetted",
            "You Have New Task has Sent",
            'New Task');
      }
      _showSuccessMessage(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return StudentHomePage();
          },
        ),
      );
    } catch (e) {
      print('Error saving task: $e');
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task Uploaded successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = widget.task!['submissionDeadline'].toDate();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Send Task ',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.task!['description']}',
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deadline: $dateTime',
                  style: TextStyle(
                    color: getColorBasedOnDeadline(
                        widget.task!['submissionDeadline']),
                  ),
                ),
                if (getColorBasedOnDeadline(
                        widget.task!['submissionDeadline']) ==
                    Colors.red)
                  const Text(
                    "You Are Late! ${Emojis.smile_loudly_crying_face}",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                downloadTaks();
              },
              icon: const Icon(Icons.attach_file),
              label: const Text('Download Task File'),
            ),
            const SizedBox(height: 20),
            if (!mark)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _selectFile();
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Task File'),
                  ),
                  Text(_fileName.isNotEmpty ? _fileName : 'NoFile'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (getColorBasedOnDeadline(
                              widget.task!['submissionDeadline']) ==
                          Colors.green) {
                        taskStatus = '1';
                      }

                      _saveTask(context);
                    },
                    child: const Text('Save Task'),
                  ),
                  if (_uploadProgress > 0.0 && _uploadProgress < 1.0)
                    LinearProgressIndicator(value: _uploadProgress),
                ],
              ),
            if (mark)
              Column(
                children: [
                  Text(
                    'Your Mark is: $marksIs/ ${widget.task!['from']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color getColorBasedOnDeadline(Timestamp deadline) {
    DateTime deadlineDateTime = deadline.toDate();

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (deadlineDateTime.isBefore(today)) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }
}
