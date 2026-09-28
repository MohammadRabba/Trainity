import 'dart:math';

import 'package:Trainity/component/Color.dart';
import 'package:Trainity/component/start.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Trainity/ChatSystem/chatSystem.dart';
import 'package:Trainity/Tracking/SuperisorTracking/ListStudents.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/matchingSystem/MatchPage.dart';
import 'package:Trainity/matchingSystem/matching.dart';
import 'package:Trainity/notification/notification.dart';
import 'package:Trainity/matchingSystem/MatchStudent.dart';
import 'package:Trainity/view/supervisor/SupervisorShoworder.dart';
import 'package:Trainity/view/supervisor/draweradmisupervisor.dart';

class SuperVisorHomePage extends StatefulWidget {
  const SuperVisorHomePage({super.key});

  @override
  State<SuperVisorHomePage> createState() => _HomePageState();
}

List<Map<String, dynamic>> notifications = [];
notification notesup = notification();
String counter = '';
late String admin;
bool isloading = false;
List<Widget Function()> pageBuilders = [
  () => const Start(),
  () => const ListStudents(),
  () => const ShowPerson(),
  () => const SuperVisorShowOrder(),
];

List<Widget> buttonpages = [
  const Start(),
  const ListStudents(),
  const ShowPerson(),

  const SuperVisorShowOrder(),

  // const Addterm(),
  // const ShowCompanyRegistrations()
];

List<String> buttontitle = [
  "Home",
  "Tracking",
  "Match Students",

  "Requests",
  // "Show Companies"
];

List<Icon> buttonicon = [
  const Icon(Icons.home),
  const Icon(Icons.list),
  const Icon(Icons.merge),

  const Icon(Icons.receipt_long_outlined),

  // const Icon(Icons.track_changes),
  // const Icon(Icons.add),
];

class _HomePageState extends State<SuperVisorHomePage> {
  int _currentIndex = 0;

  List<int> values = [0, 0, 0, 0];
  final List<Color> colors = [
    Colors.red,
    Colors.black,
    Colors.blue,
    Colors.green,
  ];
  late List<Widget> pages;

  @override
  void initState() {
    pages = pageBuilders.map((builder) => builder()).toList();

    super.initState();
    initializeData();
  }

  Future<void> matchingFunction() async {
    Matching getper = Matching();
    getper.getAllUserData();
    getper.checkStatus();
    MatchStudent gg = MatchStudent();
    await gg.getAllopp();
    await gg.getAllStudentsData();
    for (int i = 0; i < gg.studentList.length; i++) {
      List<Map<String, dynamic>> hh = [];
      List<Map<String, dynamic>> lm = [];
      gg.finalPercentage(hh, gg.studentList[i]);
      lm = gg.filterByStudentEmail(hh, gg.studentList);
      gg.addAllStudentOpp(lm, gg.studentList[i], gg.studentList[i]['email']);
    }
  }

  Future<void> initializeData() async {
    await getSt();
    await matchingFunction();

    await getadmin();
    setState(() {
      isloading = true;
    });
  }

  Future<void> resetNotes() async {
    notificationNum = 0;
    await notesup.resetNote(myid);
  }

  MatchStudent mt = new MatchStudent();
  Future<void> showStudents(
      BuildContext context, List<Map<String, dynamic>> notifications) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppBar(
                title: const Text('Students'),
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
                    notification['id'] =
                        notification['email'].toString().split('@').first;
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
                          notification['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notification['id']),
                            const SizedBox(height: 8),
                          ],
                        ),
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

  Future<void> showNotifications(
      BuildContext context, List<Map<String, dynamic>> notifications) async {
    print(notifications);
    notifications = await getNote();
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
                              notesup.getWidgetFromPayload(payload);
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

  Future<List<int>> getStudents() async {
    List<int> students = [0, 0, 0, 0];
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('type', isEqualTo: '0')
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      for (var doc in userSnapshot.docs) {
        if (doc['status'] == '0') {
          students[0] += 1;
        } else if (doc['status'] == '1') {
          students[1] += 1;
        } else if (doc['status'] == '2') {
          students[2] += 1;
        } else if (doc['status'] == '3') {
          students[3] += 1;
        }
      }
    }
    return students;
  }

  Future<void> getSt() async {
    values = await getStudents();
  }

  Future<List<Map<String, dynamic>>> getNote() async {
    List<Map<String, dynamic>> notes = [];

    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(myid)
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
      drawer: AppDrawerSuperVisor(),
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
                child: const Icon(Icons.notifications, color: Colors.white),
              ),
              onPressed: () {
                showNotifications(context, notifications);
                notesup.resetNote(myid);
              },
            ),
          if (notificationNum == 0)
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                showNotifications(context, notifications);
                notesup.resetNote(myid);
              },
            ),
        ],
        backgroundColor: const Color.fromARGB(255, 99, 95, 225),
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

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.chat),
        onPressed: _navigateToConversationsScreen,
      ),
      notificationNum != 0
          ? _buildNotificationIconWithBadge()
          : _buildNotificationIcon(),
    ];
  }

  Widget _buildNotificationIconWithBadge() {
    return IconButton(
      icon: Badge(
          label: Text("$notificationNum"),
          child: const Icon(Icons.notifications)),
      onPressed: _handleNotificationPress,
    );
  }

  Widget _buildNotificationIcon() {
    return IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: _handleNotificationPress,
    );
  }

  void _handleNotificationPress() {
    showNotifications(context, notifications);
    notesup.resetNote(myid);
  }

  void _navigateToConversationsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConversationsScreen(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Trainity",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            _buildButtonsRow(0, 1),
            _buildButtonsRow(2, 3),
            const SizedBox(height: 50),
            Center(child: TasksCircularChart(values: values, colors: colors)),
            const SizedBox(height: 50),
            _buildGridView(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsRow(int firstIndex, int secondIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTextButton(firstIndex),
        _buildTextButton(secondIndex),
      ],
    );
  }

  Widget _buildTextButton(int index) {
    return TextButton(
      onPressed: () async {
        List<Map<String, dynamic>> st = await mt.getAllStudents(index);
        showStudents(context, st);
      },
      child: Text(
        'Button Text ${values[index]}',
        style: TextStyle(color: colors[index]),
      ),
    );
  }

  Widget _buildGridView() {
    return SizedBox(
      height: 400,
      child: GridView.builder(
        itemCount: 7,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 10,
          mainAxisExtent: 125,
        ),
        itemBuilder: (context, index) => _buildGridItem(index),
      ),
    );
  }

  Widget _buildGridItem(int index) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () => _navigateToButtonPage(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: globalcolor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(buttontitle[index],
                style: const TextStyle(fontSize: 11, color: Colors.white)),
            buttonicon[index],
          ],
        ),
      ),
    );
  }

  void _navigateToButtonPage(int index) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => buttonpages[index]));
  }

  getadmin() async {
    if (myid != '') {
      await notesup.getNotificationsCounter(myid);
    }
    final prefs = await SharedPreferences.getInstance();
    const keyAdmin = 'admin';
    final valueadmin = prefs.get(keyAdmin);
    print(valueadmin.toString());
    admin = valueadmin.toString();
  }
}

class TasksCircularChart extends StatelessWidget {
  final List<int> values;
  final List<Color> colors;

  const TasksCircularChart({
    super.key,
    required this.values,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: CustomPaint(
        painter: CircularChartPainter(values, colors),
      ),
    );
  }
}

class CircularChartPainter extends CustomPainter {
  final List<int> values;
  final List<Color> colors;

  CircularChartPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    double startAngle = -pi / 2;
    double totalValue = values.reduce((sum, value) => sum + value).toDouble();

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / totalValue) * 2 * pi;

      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
