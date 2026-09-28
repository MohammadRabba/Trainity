import 'package:flutter/material.dart';
import 'package:Trainity/view/company/CompanyUpdateProfile.dart';

class ComapnyProfile extends StatefulWidget {
  const ComapnyProfile({super.key});

  @override
  State<ComapnyProfile> createState() => _ComapnyProfileState();
}

Widget _buildUserDataField(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 18, color: Colors.grey)),
      ],
    ),
  );
}

class _ComapnyProfileState extends State<ComapnyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "user name:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text("myname",
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 30,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "phone:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text("myphone",
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const CompanyProfilePage(),
                    ),
                  );
                },
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
