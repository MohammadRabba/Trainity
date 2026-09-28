import 'dart:math';

import 'package:Trainity/model/CompanyModel.dart';
import 'package:Trainity/view/supervisor/SupervisorHomePage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//ds
class ShowCompanyRegistrations extends StatefulWidget {
  const ShowCompanyRegistrations({super.key});

  @override
  _ShowCompanyRegistrationsState createState() =>
      _ShowCompanyRegistrationsState();
}

class _ShowCompanyRegistrationsState extends State<ShowCompanyRegistrations> {
  List<CompanyModel> companyRegistrations = [];

  Future<void> getAllStudentRegistrations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('waiting')
          .doc('company')
          .collection('company')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          companyRegistrations = querySnapshot.docs.map((doc) {
            return CompanyModel(
              id: doc.id,
              name: doc['name'],
              email: doc['email'],
              phone: doc['phone'],
              type: '2',
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching student registrations: $e');
    }
  }

  Future<void> approveRequest(String id) async {
    try {
      int i = 0;
      await signUpWithEmailAndPassword(i);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request approved"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
    }
  }

  Future<void> signUpWithEmailAndPassword(int i) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: companyRegistrations[i].email,
              password: generateRandomPassword(length: 10));

      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!.uid, i);
        await sendPasswordResetEmail(companyRegistrations[i].email);
        await userCredential.user?.sendEmailVerification();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Accepted',
          btnOkOnPress: () {},
        ).show();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuperVisorHomePage()),
        );

        print('Sign up successful: ${userCredential.user!.uid}');
      }
    } catch (e) {
      print('Sign up error: $e');
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

  Future<void> _createUserProfile(String userId, int i) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(userId).set({
        'name': companyRegistrations[i].name,
        'phone': companyRegistrations[i].phone,
        'email': companyRegistrations[i].email,
        'type': '1',
        'photo': '',
        'token': '',
      });
      await FirebaseFirestore.instance
          .collection('waiting')
          .doc('company')
          .collection('company')
          .doc(companyRegistrations[i].id)
          .delete();
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<void> rejectRequest(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('waiting')
          .doc('company')
          .collection('company')
          .doc(id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request approved"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SuperVisorHomePage()),
      );
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllStudentRegistrations();
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
          'Company Registrations',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: companyRegistrations.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 4.0,
            child: ListTile(
              title: Text(companyRegistrations[index].name,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(companyRegistrations[index].email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        approveRequest(companyRegistrations[index].id),
                    child: const Icon(Icons.thumb_up, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        rejectRequest(companyRegistrations[index].id),
                    child: const Icon(Icons.thumb_down, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
