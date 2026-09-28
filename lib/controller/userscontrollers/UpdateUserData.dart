import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trainity/controller/userscontrollers/Userclontroller.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/controller/userscontrollers/updateProfile.dart';
import 'package:Trainity/model/SupervisorModel.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserController _userController = UserController();
  late Future<SupervisorModel> _userData;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
  }

  Future<SupervisorModel> _fetchUserData() async {
    Map<String, dynamic> userData = await _userController.getUserData(myid);

    return SupervisorModel(
      name: userData['name'],
      email: userData['email'],
      phone: userData['phone'],
      image: userData['photo'],
    );
  }

  Future<void> uploadImageToFirebase() async {
    if (_imageFile == null) return;

    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = _imageFile!.path.split('/').last;
    Reference ref = storage.ref().child("images/$myid/$fileName");

    UploadTask uploadTask = ref.putFile(_imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    print('File Uploaded. Download Link: $downloadUrl');

    await FirebaseFirestore.instance.collection('user').doc(myid).update({
      'photo': downloadUrl,
    });
  }

  Widget _buildUserDataField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  void _navigateToUpdatePage(SupervisorModel userData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateUserProfilePage(userData: userData),
      ),
    ).then((updatedData) {
      if (updatedData != null) {
        print('Updated data received: $updatedData');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: FutureBuilder<SupervisorModel>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No Data'));
          } else {
            SupervisorModel userData = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: myphoto != ""
                        ? ClipOval(
                            child: Image.network(
                              myphoto,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Image.asset(
                              "assets/default.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  _buildUserDataField('Name:', userData.name),
                  _buildUserDataField('Phone:', userData.phone),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToUpdatePage(userData);
                    },
                    child: const Text('Update Profile'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
