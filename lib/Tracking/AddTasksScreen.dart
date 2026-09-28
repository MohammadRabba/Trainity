import 'dart:io';

import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/view/company/homepagecompany.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddTasksScreen extends StatefulWidget {
  final Future<List<String>> students;
  final String oppoId;

  const AddTasksScreen({
    super.key,
    required this.students,
    required this.oppoId,
  });

  @override
  _AddTasksScreenState createState() => _AddTasksScreenState();
}

class _AddTasksScreenState extends State<AddTasksScreen> {
  List<String> _selectedStudents = [];
  late DateTime _submissionDeadline;
  String _taskDescription = '';
  String _taskFrom = '';
  String _fileName = '';
  String _fileURL = '';
  TextEditingController _TaskTitleController = TextEditingController();
  bool _isDeadlineSelectedByUser = false;
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterStudents);

    _submissionDeadline = DateTime.now().add(const Duration(days: 7));
    widget.students.then((studentsList) {
      setState(() {
        _filteredStudents = studentsList;
      });
    });
  }

  void _filterStudents() {
    widget.students.then((studentsList) {
      setState(() {
        if (_searchController.text.isEmpty) {
          _filteredStudents = studentsList;
        } else {
          _filteredStudents = studentsList.where((student) {
            return student
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      Reference reference =
          FirebaseStorage.instance.ref().child('files').child(fileName);

      setState(() {
        _isUploading = true;
      });
      UploadTask uploadTask = reference.putFile(file);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask.whenComplete(() {});

      String downloadURL = await reference.getDownloadURL();

      setState(() {
        _fileName = fileName;
        _fileURL = downloadURL;
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<void> _selectSubmissionDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _submissionDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != _submissionDeadline) {
      setState(() {
        _submissionDeadline = pickedDate;
        _isDeadlineSelectedByUser = true;
      });
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveTask(BuildContext context) async {
    if (_TaskTitleController.text.isEmpty) {
      _showErrorMessage(context, 'Please enter a Task Description.');
      return;
    }
    if (_taskFrom.isEmpty) {
      _showErrorMessage(context, 'Please enter Task Mark.');
      return;
    }
    if (_selectedStudents.isEmpty) {
      _showErrorMessage(context, 'Please select a student.');
      return;
    }
    if (_fileName.isEmpty) {
      _showErrorMessage(context, 'Please select a file.');
      return;
    }

    if (!_isDeadlineSelectedByUser) {
      _showErrorMessage(context, 'Please select a submission deadline.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Tracking')
          .doc('taskDetails')
          .collection('Tasks')
          .add({
        'description': _taskDescription,
        'submissionDeadline': _submissionDeadline,
        'students': _selectedStudents,
        'fileName': _fileName,
        'fileURL': _fileURL,
        'oppoId': widget.oppoId,
        'mentorId': myid,
        'from': _taskFrom,
      });
      for (int i = 0; i < _selectedStudents.length; i++) {
        String token = await noteconp.getUserToken(_selectedStudents[i]);
        noteconp.sendNote(token, "You Have New Task Posted",
            "Your Have New Task", 'New Task');
        noteconp.addNote(_selectedStudents[i], "You Have New Task Posted",
            "Your Have New Task", 'New Task');
      }

      _showSuccessMessage(context);
    } catch (e) {
      print('Error saving task: $e');
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added successfully!'),
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
          'Add Tasks',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color.fromARGB(255, 95, 50, 221),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _TaskTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Task Description',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.description, color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _taskDescription = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color.fromARGB(255, 84, 76, 224),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Task Mark',
                    border: InputBorder.none,
                    prefixIcon:
                        Icon(Icons.date_range_rounded, color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _taskFrom = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _searchController,
              // onChanged: (value) {
              //   _filterStudents();
              // },
              style: TextStyle(
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: "Search Students",
                hintText: "Enter student name",
                labelStyle: TextStyle(
                  color: Colors.indigo,
                ),
                hintStyle: TextStyle(
                  color: Colors.deepPurple.shade200,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          _searchController.clear();
                          _filterStudents();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  borderSide:
                      BorderSide(color: Colors.deepPurple.shade100, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            //const SizedBox(height: 20),
            const SizedBox(height: 10),
            const Text(
              'Select Students:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<String>>(
              future: widget.students,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No students found.'),
                  );
                } else {
                  List<String> students = snapshot.data ?? [];

                  List<String> displayStudents = students.where((student) {
                    return student
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                  }).toList();

                  if (_searchController.text.isEmpty) {
                    displayStudents = snapshot.data!;
                  } else {
                    displayStudents = snapshot.data!.where((student) {
                      return student
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase());
                    }).toList();
                  }
                  if (displayStudents.isEmpty) {
                    return Center(child: Text('no students'));
                  }
                  students = snapshot.data!;
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('All Students'),
                        value: _selectedStudents.length == students.length,
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              if (value) {
                                _selectedStudents = students
                                    .map((student) => student.split('|')[1])
                                    .toList();
                              } else {
                                _selectedStudents.clear();
                              }
                            });
                          }
                        },
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          String student = _filteredStudents[index];
                          List<String> studentParts = student.split('|');
                          // String studentName = studentParts[0];
                          //  String studentId = studentParts[1];

                          final studentId = student[0];
                          return Column(
                            children: [
                              Card(
                                elevation: 3,
                                color: const Color.fromARGB(255, 84, 76, 224),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  title: Text(
                                    studentParts[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  leading: Checkbox(
                                    checkColor: Colors.black,
                                    fillColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                      (states) => Colors.white,
                                    ),
                                    value: _selectedStudents
                                        .contains(studentParts[1]),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value!) {
                                          _selectedStudents
                                              .add(studentParts[1]);
                                        } else {
                                          _selectedStudents
                                              .remove(studentParts[1]);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _selectFile();
              },
              icon: const Icon(Icons.attach_file, color: Colors.white),
              label: _isUploading
                  ? Row(
                      children: [
                        const Text(
                          'Uploading File...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircularProgressIndicator(
                          value: _uploadProgress,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ],
                    )
                  : Text(
                      'Add File ($_fileName)',
                      style: const TextStyle(color: Colors.white),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 84, 76, 224),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _selectSubmissionDeadline();
              },
              icon: const Icon(Icons.calendar_today),
              label: Text('Select Submission Deadline ($_submissionDeadline)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveTask(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 84, 76, 224),
                ),
              ),
              child: const Text(
                'Save Task',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
