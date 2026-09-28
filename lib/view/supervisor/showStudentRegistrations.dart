// import 'dart:math';

// import 'package:Trainity/model/StudentModel.dart';
// import 'package:Trainity/view/supervisor/SupervisorHomePage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ShowStudentRegistrations extends StatefulWidget {
//   const ShowStudentRegistrations({super.key});

//   @override
//   _ShowStudentRegistrationsState createState() =>
//       _ShowStudentRegistrationsState();
// }

// class _ShowStudentRegistrationsState extends State<ShowStudentRegistrations> {
//   List<StudentModel> studentRegistrations = [];

//   Future<void> getAllStudentRegistrations() async {
//     try {
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('waiting')
//           .doc('student')
//           .collection('student')
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         setState(() {
//           studentRegistrations = querySnapshot.docs.map((doc) {
//             return StudentModel(
//               id: doc.id,
//               name: doc['name'],
//               email: doc['email'],
//               phone: doc['phone'],
//               studentId: doc['studentId'],
//               photo: '',
//               status: doc['status'],
//               type: '1',
//             );
//           }).toList();
//         });
//       }
//     } catch (e) {
//       print('Error fetching student registrations: $e');
//     }
//   }

//   Future<void> approveRequest(String id) async {
//     try {
//       int i = int.parse(id);
//       _generateEmailFromId(i);
//       await signUpWithEmailAndPassword(i);

//         ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text("Request approved"),
//       backgroundColor: Colors.red,
//     ),
//   );
//     } catch (e) {
//       print('Error approving request: $e');
//     }
//   }

//   void _generateEmailFromId(int i) {
//     String id = studentRegistrations[i].studentId;
//     studentRegistrations[i].email = '$id@student.birzeit.edu';
//   }

//   Future<void> sendPasswordResetEmail(String email) async {
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//     } catch (e) {
//       print('Password reset error: $e');
//     }
//   }

//   Future<void> signUpWithEmailAndPassword(int i) async {
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//               email: studentRegistrations[i].email,
//               password: generateRandomPassword(length: 10));

//       if (userCredential.user != null) {
//         await _createUserProfile(userCredential.user!.uid, i);
//         await sendPasswordResetEmail(studentRegistrations[i].email);
//         await userCredential.user?.sendEmailVerification();

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SuperVisorHomePage()),
//         );

//         print('Sign up successful: ${userCredential.user!.uid}');
//       }
//     } catch (e) {
//       print('Sign up error: $e');
//     }
//   }

//   String generateRandomPassword({int length = 8}) {
//     const chars =
//         'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()';
//     final random = Random();
//     return String.fromCharCodes(Iterable.generate(
//       length,
//       (_) => chars.codeUnitAt(random.nextInt(chars.length)),
//     ));
//   }

//   Future<void> _createUserProfile(String userId, int i) async {
//     try {
//       await FirebaseFirestore.instance.collection('user').doc(userId).set({
//         'name': studentRegistrations[i].name,
//         'phone': studentRegistrations[i].phone,
//         'email': studentRegistrations[i].email,
//         'type': '0',
//       });
//       await FirebaseFirestore.instance
//           .collection('waiting')
//           .doc('student')
//           .collection('student')
//           .doc(studentRegistrations[i].id)
//           .delete();
//     } catch (e) {
//       print('Error creating user profile: $e');
//     }
//   }

//   Future<void> rejectRequest(String id) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('waiting')
//           .doc('student')
//           .collection('student')
//           .doc(id)
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text("Request rejected"),
//       backgroundColor: Colors.red,
//     ),
//   );
//     } catch (e) {
//       print('Error rejecting request: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getAllStudentRegistrations();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Registrations'),
//       ),
//       body: ListView.builder(
//         itemCount: studentRegistrations.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(studentRegistrations[index].name),
//             subtitle: Text(studentRegistrations[index].email),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.thumb_up),
//                   onPressed: () {
//                     approveRequest(studentRegistrations[index].id);
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.thumb_down),
//                   onPressed: () =>
//                       rejectRequest(studentRegistrations[index].id),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
