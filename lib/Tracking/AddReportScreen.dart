import 'dart:io';

import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/view/company/homepagecompany.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddReportScreen extends StatefulWidget {
  final Future<List<String>> students;

  const AddReportScreen({
    super.key,
    required this.students,
    required String oppoId,
  });

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  List<String> _selectedStudents = [];

  String _taskDescription = '';
  String _fileName = '';
  String _fileURL = '';
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  UploadTask? _uploadTask;
  TextEditingController _TaskTitleController = TextEditingController();
//bool _isDeadlineSelectedByUser = false;
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterStudents);

    // _submissionDeadline = DateTime.now().add(const Duration(days: 7));
    widget.students.then((studentsList) {
      setState(() {
        _filteredStudents = studentsList;
      });
    });
  }

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    if (_searchController.text.isEmpty) {
      widget.students.then((studentsList) {
        setState(() {
          _filteredStudents = studentsList;
        });
      });
    } else {
      widget.students.then((studentsList) {
        setState(() {
          _filteredStudents = studentsList.where((student) {
            return student
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();
        });
      });
    }
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      Reference reference =
          FirebaseStorage.instance.ref().child('Reports').child(fileName);

      _uploadTask = reference.putFile(file);

      _uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
      });

      setState(() {
        _isUploading = true;
      });

      await _uploadTask!.whenComplete(() {
        setState(() {
          _isUploading = false;
        });
      });

      String downloadURL = await reference.getDownloadURL();

      setState(() {
        _fileName = fileName;
        _fileURL = downloadURL;
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

  Future<void> _saveReport(BuildContext context) async {
    if (_TaskTitleController.text.isEmpty) {
      _showErrorMessage(context, 'Please enter a report title.');
      return;
    }
    if (_fileName.isEmpty) {
      _showErrorMessage(context, 'Please select a file.');
      return;
    }
    if (_selectedStudents.isEmpty) {
      _showErrorMessage(context, 'Please select a student.');
      return;
    }
    try {
      if (_TaskTitleController.text.isNotEmpty &&
          _TaskTitleController.text.isNotEmpty &&
          _selectedStudents.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Tracking')
            .doc('reportkDetails')
            .collection('Reports')
            .add({
          'description': _taskDescription,
          'date': DateTime.now(),
          'student': _selectedStudents,
          'fileName': _fileName,
          'mentorId': myid,
          'mentor_comment': '',
          'fileURL': _fileURL,
          'comment': '',
          'Supercomment': '',
        });
        for (int i = 0; i < _selectedStudents.length; i++) {
          String token = await noteconp.getUserToken(_selectedStudents[i]);
          noteconp.sendNote(token, "You Have New Report Submetted",
              "You Mentor Send New Report", 'New Report');
          noteconp.addNote(
              _selectedStudents[i],
              "You Have New Report Submetted",
              "You Mentor Send New Report",
              'New Report');
        }

        _showSuccessMessage(context);

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving report: $e');
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report Added Successfully!'),
        backgroundColor: Colors.green,
      ),
    );
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
          'Add Report',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color.fromARGB(255, 84, 76, 224),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _TaskTitleController,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Report Title',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.description, color: Colors.white),
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
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
                color: const Color.fromARGB(255, 84, 76, 224),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: const Text('Select File',
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                  subtitle: Text('Add File ($_fileName)',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255))),
                  onTap: () {
                    _selectFile();
                  },
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
                                      style:
                                          const TextStyle(color: Colors.white),
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
              ElevatedButton(
                onPressed: () {
                  _saveReport(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isUploading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Uploading File...'),
                          const SizedBox(width: 10),
                          CircularProgressIndicator(
                            value: _uploadProgress,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ],
                      )
                    : const Text(
                        'Save Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          //  color: Color.fromARGB(2, 2, , b)
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
