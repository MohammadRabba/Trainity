import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/studentTrackPage.dart';
import 'package:Trainity/authentication/login.dart';
import 'package:Trainity/view/company/homepagecompany.dart';
import 'package:Trainity/view/manager/managerhomepage.dart';
import 'package:Trainity/view/student/homepage.dart';
import 'package:Trainity/view/supervisor/SupervisorHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Trainity/notification/notification.dart';

String myname = '';
String myid = '';
String myphoto = '';
String myphone = '';
String myemail = '';
String userType = '';
String mytoken = '';
String status = '0';
int notificationNum = 0;
notification note = notification();
List<Map<String, dynamic>> notifications = [];

class LoginController {
  Future<void> signInWithEmailAndPassword(
      String email, String password, context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await fetchUserData(user.uid, context);
        myid = user.uid;
        myname = user.displayName!;
        myemail = user.email!;
        mytoken = await note.getToken(userType);
        if (myid != '') {
          await note.getNotificationsCounter(myid);
        }
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Email or Password are wrong,Try again',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Email or Password are wrong,Try again',
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void> fetchUserData(String userId, BuildContext context) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data();
        if (userData != null) {
          myname = userSnapshot['name'];
          myphone = userSnapshot['phone'];
          myemail = userSnapshot['email'];
          myphoto = userSnapshot['photo']!;
          userType = userSnapshot['type'];
          mytoken = userSnapshot['token'];
          User? user = FirebaseAuth.instance.currentUser;
          if (userType == '0') {
            status = userSnapshot['status'];
          }
          user?.updateDisplayName(myname);

          navigateBasedOnUserType(userType, status, context);
        }
        DocumentSnapshot notSnap = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('notifications')
            .doc('counter')
            .get();
        if (notSnap.exists) {
          notificationNum = notSnap['counter'];
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void navigateBasedOnUserType(
      String userType, String status, BuildContext context) {
    if (userType == "0") {
      note.saveStudentToken(mytoken);
      if (status == '3') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const StudentHomePage()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const HomePage()));
      }
    } else if (userType == "2") {
      note.saveSupervisorToken(mytoken);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const SuperVisorHomePage()));
    } else if (userType == "3") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const ManagerHomePage()));
    } else if (userType == "1") {
      note.saveCompanyToken(mytoken);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePageCompany()));
    } else {
      print('Invalid userType: $userType');
    }
  }

  void showSuccessDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'We sent an email verification. Please verify your email.',
      btnOkOnPress: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const LoginPage()));
      },
    ).show();
  }

  printmydata() async {
    final prefs = await SharedPreferences.getInstance();

    const keyName = 'name';
    final valueudername = prefs.get(keyName);
    myname = valueudername.toString();
  }

  getuserid() async {
    final prefs = await SharedPreferences.getInstance();

    const keyUserId = 'user_id';
    return prefs.get(keyUserId);
  }

  getname() async {
    final prefs = await SharedPreferences.getInstance();

    const keyUserId = 'name';
    return prefs.get(keyUserId);
  }
}
