import 'package:flutter/material.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/controller/userscontrollers/updateProfile.dart';
import 'package:Trainity/model/SupervisorModel.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  late Future<SupervisorModel> _userData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Image.network(
                    myphoto.isNotEmpty ? myphoto : "assets/default.png",
                    fit: BoxFit.cover,
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
}
