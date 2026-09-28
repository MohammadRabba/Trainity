import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Trainity/authentication/login.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/model/SupervisorModel.dart';

class UpdateUserProfilePage extends StatefulWidget {
  final SupervisorModel userData;

  const UpdateUserProfilePage({super.key, required this.userData});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateUserProfilePage> {
  late TextEditingController _nameController;
  String selectedLocation = 'Ramallah';
  late TextEditingController _phoneController;
  File? _imageFile;
  late String image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    selectedLocation = widget.userData.address ?? 'Ramallah';
    _phoneController = TextEditingController(text: widget.userData.phone);
  }

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {}
    });
  }

  Future<void> saveChanges() async {
    uploadImageToFirebase();
    await FirebaseFirestore.instance.collection('user').doc(myid).update({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'location': selectedLocation,
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false);
  }

  Future<void> uploadImageToFirebase() async {
    if (_imageFile == null) return;

    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = _imageFile!.path.split('/').last;
    Reference ref = storage.ref().child("images/$myid/$fileName");

    UploadTask uploadTask = ref.putFile(_imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    image = downloadUrl;
    print('File Uploaded. Download Link: $downloadUrl');

    await FirebaseFirestore.instance.collection('user').doc(myid).update({
      'photo': downloadUrl,
    });
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
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
            _buildTextField('Name', _nameController),
            _buildTextField('Phone', _phoneController),
            const Text(
              'Location of Opportunity',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLocation = newValue!;
                });
              },
              items: <String>[
                'Ramallah',
                'Jenin',
                'Nablus',
                'Tolkarem',
                'BethLahem',
                'Toubas',
                'Hebron',
                'From Home(Remotly)',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            _imageFile == null ? const Text('') : Image.file(_imageFile!),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
