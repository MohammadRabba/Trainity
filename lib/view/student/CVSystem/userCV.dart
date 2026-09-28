import 'dart:io';
import 'dart:typed_data';

import 'package:Trainity/controller/cvcontroller/getcv.dart';
import 'package:Trainity/controller/cvcontroller/updatecv.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/model/CVModel.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserCV extends StatefulWidget {
  const UserCV({super.key});

  @override
  State<UserCV> createState() => _UserProfileState();
}

final FirebaseStorage _storage = FirebaseStorage.instance;

GetCVController _controller = GetCVController();
late CVModel mycv;
bool isloading = false;
double downloadProgress = 0;

class _UserProfileState extends State<UserCV> {
  @override
  void initState() {
    _controller.getCV().then((value) {
      mycv = value!;
      setState(() {
        isloading = true;
      });
    });
    super.initState();
  }

  void _launchURL(String url) async {
    try {
      if (await canLaunch(Uri.encodeFull(url))) {
        await launch(Uri.encodeFull(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'User CV',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: isloading
          ? Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Performances:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: mycv.perference.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(mycv.perference[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "CV File: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () async {
                      downloadCVFile(mycv.cvFile);
                    },
                    child: Text(
                      '${mycv.cvFile}',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      List<dynamic> languages = mycv.perference;
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              UpdateCv(languages: languages)));
                    },
                    child: const Text('Update Information'),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> downloadCVFile(String fileName) async {
    try {
      Reference storageReference = _storage.ref('CVs/$myid/$fileName');
      Uint8List? fileBytes = await storageReference.getData();

      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/$fileName';

      File file = File(filePath);
      await file.writeAsBytes(fileBytes!);
      String url = await storageReference.getDownloadURL();
      _launchURL(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CV downloaded to $filePath'),
          backgroundColor: Colors.green,
        ),
      );
      createnewnote('Downloaded Complete', ' CV downloaded to $filePath');
    } catch (e) {
      print('Error downloading assignment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error downloading assignment"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
