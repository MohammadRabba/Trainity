import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/supervisor/draweradmisupervisor.dart';

class ListFilesInStorage extends StatefulWidget {
  const ListFilesInStorage({super.key});

  @override
  _ListFilesInStorageState createState() => _ListFilesInStorageState();
}

class _ListFilesInStorageState extends State<ListFilesInStorage> {
  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
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

  Future<void> upload(String fileName, File fileContent) async {
    try {
      Reference storageRef =
          FirebaseStorage.instance.ref().child('csv/$fileName');

      UploadTask uploadTask = storageRef.putFile(fileContent);
      await uploadTask.whenComplete(() {
        print('File uploaded');
        readCSV(fileName);
      });
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

  Future<void> readCSV(String fileName) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference csvRef = storage.ref().child('csv/$fileName');

      Directory tempDir = Directory.systemTemp;
      File tempFile = File('${tempDir.path}/$fileName');

      await csvRef.writeToFile(tempFile);

      List<List<dynamic>>? csvData = await readCSVFromFile(tempFile);

      print(csvData);
    } catch (e) {
      print('Error reading CSV file: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
    }
  }

  Future<void> getFileDownloadUrl() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('csv');

      ListResult result = await ref.listAll();

      String url = result.items.first.name;
      print(url);
      Reference ref2 = storage.ref().child('csv/$url');
      if (url != '') {
        await ref2.delete();
      } else {
        print('error');
      }
    } catch (e) {
      print('Error getting file download URL: $e');
    }
  }

  Future<void> deleteFileFromStorage(String filePath) async {
    try {
      File file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('File deleted successfully');
      } else {
        print('File does not exist');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Future<void> signUpWithEmailAndPassword(
      String name,
      String email,
      String id,
      String phone,
      String location,
      String algorithm,
      String database,
      String structure,
      String gpa) async {
    try {
      var existingUser =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      print(existingUser);

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: generateRandomPassword(length: 10),
      );
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        await sendPasswordResetEmail(email);

        print('Sign up successful: ${userCredential.user!.uid}');

        var userId = userCredential.user!.uid;
        await createUserProfile(name, userId, email, id, phone, location,
            algorithm, database, structure, gpa);
      }
      createnewnote('User Created Successfully', ' User Added Successfully');
    } catch (e) {
      print('Sign up error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('User already exists with this email: $email'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
  }

  String generateRandomPassword({int length = 8}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  Future<void> createUserProfile(
      String name,
      String userId,
      String email,
      String id,
      String phone,
      String location,
      String algorithm,
      String database,
      String structure,
      String gpa) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(userId).set({
        'name': name,
        'phone': phone,
        'email': '$id@student.birzeit.edu',
        'type': '0',
        'location': location,
        'Algorithm': algorithm,
        'Structure': structure,
        'DataBase': database,
        'GPA': gpa,
        'status': '0',
        'token': '',
        'photo': '',
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<List<List<dynamic>>?> readCSVFromFile(File file) async {
    try {
      String contents = await file.readAsString();
      List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter().convert(contents);
      print(contents);
      if (rowsAsListOfValues.isNotEmpty) {
        rowsAsListOfValues.removeAt(0);
      }

      for (int i = 0; i < rowsAsListOfValues.length; i++) {
        List<dynamic> columnData = rowsAsListOfValues[i];
        print('length: ${rowsAsListOfValues.length}');
        for (int j = 0; j < columnData.length; j++) {
          print('Row $i, Column $j: ${columnData[j]}');
        }

        String mail = columnData[2].toString();
        signUpWithEmailAndPassword(
          columnData[0].toString(), // Name
          '$mail@student.birzeit.edu', // Email
          columnData[2].toString(), // ID
          columnData[1].toString(), // Phone
          columnData[3].toString(), // Location
          columnData[4].toString(), // Algorithm
          columnData[5].toString(), // Database
          columnData[6].toString(), // Structure
          columnData[7].toString(), // GPA
        );
      }
    } catch (e) {
      print('Error reading CSV file: $e');
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawerSuperVisor(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Upload and Register Students',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                uploadFile();
              },
              child: const Text('Select and Upload CSV'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
