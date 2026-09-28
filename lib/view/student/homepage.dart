import 'dart:math';

import 'package:Trainity/component/start.dart';
import 'package:Trainity/view/student/oldorder.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Trainity/ChatSystem/chatSystem.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/notification/notification.dart';
import 'package:Trainity/view/student/drawerstudent.dart';
import 'package:Trainity/view/student/showtraining.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<Map<String, dynamic>> notifications = [];
late String admin;
bool isloading = false;

List<Widget Function()> pageBuilders = [
  () => Start(),
  () => const ShowTraining(),
  () => const OldOrder(),
];

List<String> buttontitle = [
  "Home",
  "show opportunity",
  "Old Orders",
];
notification notest = notification();
List<dynamic> notific = [];
List<Icon> buttonicon = [
  const Icon(Icons.home),
  const Icon(Icons.work),
  const Icon(Icons.list),
];

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    pages = pageBuilders.map((builder) => builder()).toList();

    print(notific);
    getadmin().whenComplete(() {
      setState(() {
        isloading = true;
      });
    });

    super.initState();
  }

  Future<void> showNotifications(
      BuildContext context, List<Map<String, dynamic>> notifications) async {
    notifications = await getNote(myid);
    print(notifications);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppBar(
                title: const Text('Notifications'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      resetNotes();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    final notification = notifications[index];
                    Timestamp timestamp = notification['time'];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          child: Icon(Icons.notifications),
                        ),
                        title: Text(
                          notification['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notification['body']),
                            const SizedBox(height: 8),
                            Text(
                              timestamp.toDate().toString(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          String payload = notification['payload'] as String;
                          Widget widgetToShow =
                              notest.getWidgetFromPayload(payload);
                          resetNotes();
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return widgetToShow;
                          }));
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> resetNotes() async {
    notificationNum = 0;
    await notest.resetNote(myid);
  }

  Future<List<Map<String, dynamic>>> getNote(String id) async {
    List<Map<String, dynamic>> notes = [];

    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(id)
          .collection('notifications')
          .orderBy('time', descending: true)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        for (var doc in userSnapshot.docs) {
          Map<String, dynamic> notificationData =
              doc.data() as Map<String, dynamic>;
          notes.add(notificationData);
        }
      }
      return notes;
    } catch (e) {
      print('Error getting notifications: $e');
    }

    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerStudent(),
      appBar: AppBar(
        title: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            return Text('Welcome $myname',
                style: const TextStyle(color: Colors.white));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConversationsScreen(),
                ),
              );
            },
          ),
          if (notificationNum != 0)
            IconButton(
              icon: Badge(
                label: Text("$notificationNum"),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                showNotifications(context, notifications);
                notest.resetNote(myid);
              },
            ),
          if (notificationNum == 0)
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              onPressed: () {
                showNotifications(context, notifications);
                notest.resetNote(myid);
              },
            ),
        ],
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: const Color.fromARGB(255, 99, 95, 225),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: List.generate(
          min(buttontitle.length, 4),
          (index) => BottomNavyBarItem(
            icon: buttonicon[index],
            title: Text(buttontitle[index]),
            activeColor: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 81, 181),
      ),
    );
  }

  void sendEmailVerification() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      user.sendEmailVerification();
    } else {}
  }

  void checkEmailVerification() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Email Verification Required'),
            content: const Text(
                'Your email is not verified. We sent to you a mail,Please verify your email to continue.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  getadmin() async {
    await notest.getNotificationsCounter(myid);

    final prefs = await SharedPreferences.getInstance();
    const keyAdmin = 'admin';
    final valueadmin = prefs.get(keyAdmin);
    print(valueadmin.toString());
    admin = valueadmin.toString();
  }
}
