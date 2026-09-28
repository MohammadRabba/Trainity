import 'dart:math';

import 'package:Trainity/component/start.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Trainity/ChatSystem/chatSystem.dart';
import 'package:Trainity/Tracking/SuperisorTracking/studentAttendence.dart';
import 'package:Trainity/Tracking/getReport.dart';
import 'package:Trainity/Tracking/showTasksList.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/notification/notification.dart';
import 'package:Trainity/view/student/drawerstudent.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

List<Map<String, dynamic>> notifications = [];
notification notest = notification();
String counter = '';
late String admin;
String oppo_id = '';

bool isloading = false;
List<Widget Function()> pageBuilders = [
  () => const Start(),
  () => const StudentsAttendance(),
  () => const ShowReports(),
  () => const ShowTasks(),
];

List<String> buttontitle = [
  "Home",
  "Attendence",
  "Reports",
  "Tasks",
];

List<Icon> buttonicon = [
  const Icon(Icons.home),
  const Icon(Icons.present_to_all),
  const Icon(Icons.add_to_photos_outlined),
  const Icon(Icons.add),
];

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    pages = pageBuilders.map((builder) => builder()).toList();

    getoppoId();
    getadmin().whenComplete(() {
      setState(() {
        isloading = true;
      });
    });

    super.initState();
  }

  Future<void> getoppoId() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('Training')
          .where('listOfStudents', arrayContains: myid)
          .get();

      if (query.docs.isNotEmpty) {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;

        oppo_id = data['oppo_id'] as String;
      }
    } catch (e) {
      print('Error getting oppo_id: $e');
    }
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
      counter = notes.length.toString();

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
              color: Colors.white,
              icon: Badge(
                  label: Text("$notificationNum"),
                  child: const Icon(Icons.notifications)),
              onPressed: () {
                showNotifications(context, notifications);
                notest.resetNote(myid);
              },
            ),
          if (notificationNum == 0)
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.notifications),
              onPressed: () {
                showNotifications(context, notifications);
                notest.resetNote(myid);
              },
            ),
        ],
        backgroundColor: Colors.indigo,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: List.generate(
          min(buttontitle.length, 5),
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

  getadmin() async {
    if (myid != '') {
      await notest.getNotificationsCounter(myid);
    }
    final prefs = await SharedPreferences.getInstance();
    const keyAdmin = 'admin';
    final valueadmin = prefs.get(keyAdmin);
    print(valueadmin.toString());
    admin = valueadmin.toString();
  }
}
