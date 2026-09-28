import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/studentTrackPage.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/student/CVSystem/userCV.dart';

class AddCv extends StatefulWidget {
  const AddCv({super.key});

  @override
  _AddCvState createState() => _AddCvState();
}

class _AddCvState extends State<AddCv> {
  File? _pickedFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String uplodate = '';
  String downloadURL = '';

  Future<void> upload(String fileName, File fileContent) async {
    try {
      Reference storageRef =
          FirebaseStorage.instance.ref().child('CVs/$myid/$fileName');

      UploadTask uploadTask = storageRef.putFile(fileContent);

      await uploadTask;

      uplodate = storageRef.name;

      downloadURL = await storageRef.getDownloadURL();

      print('File uploaded');
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Failed Upload File',
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void> getFileDownloadUrl() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('CVs/$myid');

      ListResult result = await ref.listAll();

      String url = result.items.first.name;
      print(url);
      Reference ref2 = storage.ref().child('CVs/$myid/$url');
      if (url != '') {
        await ref2.delete();
      } else {
        print('error');
      }
    } catch (e) {
      print('Error getting file download URL: $e');
    }
  }

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'png', 'jpg', 'jpeg', 'doc', 'pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      File fileContent = File(file.path!);
      String fileName = file.name;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Upload Confirmation'),
            content: Text('Are you sure you want to upload $fileName?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Upload'),
                onPressed: () {
                  getFileDownloadUrl();
                  upload(fileName, fileContent);
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
    } else {}
  }

  Future<void> addCv(List<String> achievement, String cv) async {
    DocumentReference opportunities = FirebaseFirestore.instance
        .collection('user')
        .doc(myid)
        .collection('CV')
        .doc(myid);

    try {
      await opportunities.set({
        'pereferences': achievement,
        'user_id': myid,
        'cv': cv,
        'name': myname,
        'url': downloadURL,
      });

      createnewnote('CV Added', 'CV Added Successfully');
    } catch (error) {
      createnewnote('CV didnt Added', 'CV Failed to Add');

      print('Error adding CV: $error');
    }
  }

  Map<String, Map<String, List<String>>> categorizedItems = {
    'Front-end': {
      'Languages': ['JavaScript', 'HTML', 'CSS'],
      'Frameworks': ['React', 'Angular', 'Vue'],
    },
    'Back-end': {
      'Languages': ['Node.js', 'Python', 'Ruby', 'Java', 'PHP'],
    },
    'Testing': {
      'Frameworks': ['Selenium', 'Jest', 'JUnit', 'Cypress'],
    },
    'Full-stack': {
      'Languages': ['JavaScript', 'Python', 'Java'],
      'Frameworks': ['MEAN', 'MERN', 'LAMP', 'Django'],
    },
  };

  List<String> selectedItems = [];
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
          'Add New CV',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 100, color: Colors.indigo),
                ExpansionTile(
                  title: const Text(
                    'Select Programming Languages and Frameworks',
                  ),
                  children: categorizedItems.keys.map((category) {
                    return ExpansionTile(
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children:
                          categorizedItems[category]!.entries.map((entry) {
                        return ExpansionTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          children: entry.value.map((item) {
                            return CheckboxListTile(
                              title: Text(item),
                              value: selectedItems.contains(item),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null && value) {
                                    selectedItems.add(item);
                                  } else {
                                    selectedItems.remove(item);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  onPressed: () {
                    uploadFile();
                  },
                  child: const Text(
                    'Select and Upload CV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_pickedFile != null)
                  Text(
                    'File selected: ${_pickedFile!.path}',
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  onPressed: () {
                    getFileDownloadUrl();
                    addCv(selectedItems, uplodate);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const UserCV();
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Save CV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
