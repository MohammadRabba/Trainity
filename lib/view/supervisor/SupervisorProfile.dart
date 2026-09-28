import 'dart:io';

import 'package:Trainity/controller/usersControllers/UpdateSupervisorProfile.dart';
import 'package:Trainity/controller/userscontrollers/Userclontroller.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/model/SupervisorModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class supervisourprofile extends StatefulWidget {
  const supervisourprofile({super.key});

  @override
  _CompanyProfilePageState createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<supervisourprofile> {
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

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
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
          Text(value, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  void _navigateToUpdatePage(SupervisorModel userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => supervisourUpdateProfile(userData: userData),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
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
                  const SizedBox(height: 20),
                  _buildUserInfoCard('Name', userData.name),
                  _buildUserInfoCard('Phone', userData.phone),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToUpdatePage(userData);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black,
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserInfoCard(String title, String value) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      shadowColor: Colors.indigo.withOpacity(0.5),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.indigo,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}
