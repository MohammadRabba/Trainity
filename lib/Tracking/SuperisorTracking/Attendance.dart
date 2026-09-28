import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Attendance extends StatefulWidget {
  final String studentId;

  const Attendance({super.key, required this.studentId});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  int fullAttendance = 0;
  int present = 0;
  int ubsAttendance = 0;
  @override
  void initState() {
    initializing();
    super.initState();
  }

  Future<void> initializing() async {
    await getoppoId;
    await _fetchTasksAttendence();
  }

  Future<String> getoppoId() async {
    try {
      String oppo_id = '';
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('Training')
          .where('listOfStudents', arrayContains: widget.studentId)
          .get();

      if (query.docs.isNotEmpty) {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;

        oppo_id = data['oppo_id'] as String;
      }
      return oppo_id;
    } catch (e) {
      print('Error getting oppo_id: $e');
      return '';
    }
  }

  Future<void> _fetchTasksAttendence() async {
    String oppo = await getoppoId();
    FirebaseFirestore.instance
        .collection('Tracking')
        .doc('attendanceDetails')
        .collection(oppo)
        .where(widget.studentId)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          fullAttendance = fullAttendance + 1;
          if (doc[widget.studentId] == true) {
            present = present + 1;
          } else {
            ubsAttendance = ubsAttendance + 1;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    ubsAttendance = 0;
    present = 0;
    fullAttendance = 0;
  }

  @override
  Widget build(BuildContext context) {
    double progress;
    if (fullAttendance == 0) {
      progress = 0.0;
    } else {
      progress = present / fullAttendance;
    }

    if (progress.isNaN || progress.isInfinite) {
      progress = 0.0;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Show Attendence',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade400,
                        ),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Present: $present / $fullAttendance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_view_month, color: Colors.green),
                title: Text("Full Attendance Days: $fullAttendance"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.blue),
                title: Text("Present Days: $present"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_view_day, color: Colors.red),
                title: Text("Absent Days: $ubsAttendance"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceCircularProgress extends StatelessWidget {
  final int fullAttendance;
  final int present;
  final int ubsAttendance;

  const AttendanceCircularProgress({
    super.key,
    required this.fullAttendance,
    required this.present,
    required this.ubsAttendance,
    required this.value,
    required this.size,
  });

  final double value;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CircularProgressPainter(progress: value),
            ),
          ),
          Text(
            '${(value * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;

  _CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width,
          height: size.height),
      math.pi * 1.5,
      math.pi * 2 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
