import 'package:Trainity/component/start.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Trainity/ChatSystem/chatSystem.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/model/orderModel.dart';
import 'package:Trainity/notification/notification.dart';
import 'package:Trainity/view/company/drawer.dart';
import 'package:Trainity/view/company/getTraining.dart';
import 'package:Trainity/view/company/showorder.dart';

class HomePageCompany extends StatefulWidget {
  const HomePageCompany({super.key});
  @override
  State<HomePageCompany> createState() => _HomePageState();
}

notification noteconp = notification();
late String admin;
bool isloading = false;
List<OrderModel> order = [];

class _HomePageState extends State<HomePageCompany> {
  late String admin;
  bool isloading = false;
  late List<OrderModel> order;

  List<Widget Function()> pageBuilders = [
    () => Start(),
    () => const GetAllCompanyTraining(),
    () => const ShowOrder(),
  ];
  late List<Widget> pages;

  List<String> buttontitle = [
    "Home Page",
    "All Oppo",
    "Orders",
  ];
  List<Icon> buttonicon = [
    const Icon(Icons.home),
    const Icon(Icons.list),
    const Icon(Icons.list_alt_sharp),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    pages = pageBuilders.map((builder) => builder()).toList();
    getAdmin().whenComplete(() {
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
                              noteconp.getWidgetFromPayload(payload);

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
                noteconp.resetNote(myid);
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
                noteconp.resetNote(myid);
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
          buttontitle.length,
          (index) => BottomNavyBarItem(
            icon: buttonicon[index],
            title: Text(buttontitle[index]),
            activeColor: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      drawer: const AppDrawer(),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    );
  }

  Future<void> getAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    const keyAdmin = 'admin';
    final valueadmin = prefs.getString(keyAdmin);
    print(valueadmin.toString());
    admin = valueadmin ?? "";
  }
}

class NavigationRailDrawer extends StatelessWidget {
  final ValueChanged<int> onDestinationSelected;
  final int selectedIndex;

  const NavigationRailDrawer({
    super.key,
    required this.onDestinationSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    //   colors: [Color.fromARGB(255, 150, 164, 243), Color.fromARGB(255, 255, 255, 255)],

    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 40, 50, 70),
        width: 150.0,
        child: Row(
          children: [
            NavigationRail(
              destinations: [
                for (int index = 0; index < 4; index++)
                  NavigationRailDestination(
                    icon: _getIcon(index),
                    label: _getLabel(index),
                  ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.selected,
              selectedLabelTextStyle:
                  const TextStyle(color: Color.fromARGB(255, 82, 166, 234)),
              unselectedLabelTextStyle: const TextStyle(color: Colors.black),
              backgroundColor: const Color.fromARGB(255, 97, 85, 234),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getIcon(int index) {
    switch (index) {
      case 1:
        return const Icon(Icons.person);
      case 2:
        return const Icon(Icons.settings);
      case 3:
        return const Icon(Icons.list);
      case 4:
        return const Icon(Icons.notification_add);
      default:
        return const Icon(Icons.error);
    }
  }

  Text _getLabel(int index) {
    switch (index) {
      case 1:
        return const Text("Company Profile");
      case 2:
        return const Text("Setting");
      case 3:
        return const Text("Get All Oppo");
      case 4:
        return const Text("Notification");
      default:
        return const Text("Error");
    }
  }
}
