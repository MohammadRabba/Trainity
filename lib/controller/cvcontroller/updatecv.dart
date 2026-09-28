import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/student/CVSystem/userCV.dart';

class UpdateCv extends StatefulWidget {
  List<dynamic>? languages;
  UpdateCv({super.key, this.languages});

  @override
  _UpdateCvState createState() => _UpdateCvState();
}

class _UpdateCvState extends State<UpdateCv> {
  File? _pickedFile;
  List<dynamic> selectedItems = [];

  @override
  void initState() {
    initialized();
    super.initState();
  }

  Future<void> initialized() async {
    selectedItems = widget.languages ?? [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  String uplodate = mycv.cvFile;

  Future<String> upload(String fileName, File fileContent) async {
    try {
      Reference storageRef =
          FirebaseStorage.instance.ref().child('CVs/$myid/$fileName');

      UploadTask uploadTask = storageRef.putFile(fileContent);

      uplodate = storageRef.name;
      await uploadTask.whenComplete(() {
        createnewnote('CV Added', 'CV Added Successfully');
        return uplodate;
      });
    } catch (e) {
      createnewnote('CV Failed', 'CV Failed to Add');

      return '';
    }
    return uplodate;
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

  Future<void> updateCv(List<dynamic> achievement, String cv) async {
    DocumentReference opportunities = FirebaseFirestore.instance
        .collection('user')
        .doc(myid)
        .collection('CV')
        .doc(myid);

    try {
      await opportunities.update({
        'pereferences': achievement,
        'user_id': myid,
        'cv': cv,
        'name': myname,
      });

      createnewnote('CV Update', 'CV Updated Successfully');
    } catch (e) {
      createnewnote('CV Didnt Updated', 'CV Failed to Updated');
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

  void getSelectedItems() {
    List<String> newSelectedItems = [];

    for (var category in categorizedItems.keys) {
      for (var entry in categorizedItems[category]!.entries) {
        for (var item in entry.value) {
          if (widget.languages?.contains(item) == true) {
            newSelectedItems.add(item);
          }
        }
      }
    }

    setState(() {
      selectedItems = newSelectedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => UserCV()));
          },
        ),
        title: Text(
          'Update CV',
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
                ExpansionTile(
                  title: const Text(
                    'Select Programming Languages and Frameworks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  onPressed: () {
                    getFileDownloadUrl();
                    uploadFile();
                  },
                  child: const Text('Select and Upload CV'),
                ),
                const SizedBox(height: 20),
                if (_pickedFile != null)
                  Text('File selected: ${_pickedFile!.path}'),
                ElevatedButton(
                  onPressed: () {
                    updateCv(selectedItems, uplodate);
                  },
                  child: const Text('Update CV'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
