import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/sendTask.dart';
import 'package:Trainity/controller/trakingController/getTasks.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';

class ShowTasks extends StatefulWidget {
  const ShowTasks({super.key});

  @override
  State<ShowTasks> createState() => _ShowTasksState();
}

class _ShowTasksState extends State<ShowTasks> {
  final GetTasksController _getTasksController = GetTasksController();
  late Stream<List<Map<String, dynamic>>> ordersStream;
  int notYet = 0;
  List<int> values = [0, 0, 0, 0, 0];
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization() async {
    values = [0, 0, 0, 0, 0];
    ordersStream = _getTasksController.getTasksStream(myid);
    List<Map<String, dynamic>> tasks = [];
    fetchProgress(tasks);
  }

  Future<int> getLength() async {
    int tasksLength = 0;
    QuerySnapshot q = await FirebaseFirestore.instance
        .collection('Tracking')
        .doc('taskDetails')
        .collection('Tasks')
        .where('students', arrayContains: myid)
        .get();
    tasksLength = q.size;
    notYet = tasksLength;
    return tasksLength;
  }

  void fetchProgress(List<Map<String, dynamic>> orders) {
    _subscription = FirebaseFirestore.instance
        .collection('Tracking')
        .doc('taskDetails')
        .collection('TasksResults')
        .where('student_id', isEqualTo: myid)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        orders.add({
          "id": doc.id,
          "fileName": doc['fileName'],
          "fileURL": doc['fileURL'],
          "submissionDeadline": doc['submissionDeadline'],
          "description": doc['description'],
          'status': doc['status'],
          'from': doc['from'],
        });
      }
      print(orders);

      List<int> result = await getProgress(orders);
      if (mounted) {
        setState(() {
          values = result;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<List<int>> getProgress(List<Map<String, dynamic>> tasks) async {
    notYet = await getLength();
    List<int> result = [0, 0, 0, 0, 0];
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i]['status'] == '1') {
        //sent
        result[0] += 1;
      } else if (tasks[i]['status'] == '2') {
        //updated
        result[1] += 1;
      } else if (tasks[i]['status'] == '3') {
        //late
        result[2] += 1;
      } else if (tasks[i]['status'] == '4') {
        //marked
        result[4] += 1;
      }
    }
    //remaining
    print(notYet);
    result[3] = ((((notYet - result[2]) - result[1]) - result[0]) - result[4]);
    //2-0-0-1-0=1
    print(result);
    values = result;
    return result;
  }

  Color getColorBasedOnStatus(String st) {
    if (st == '1' || st == '2') {
      return Colors.green;
    } else if (st == '3') {
      return Colors.red;
    } else if (st == '4') {
      return Color.fromARGB(255, 6, 2, 255);
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.green,
      Colors.green,
      Colors.red,
      Colors.blue,
      const Color.fromARGB(255, 6, 2, 255),
    ];
    print('values:$values\n');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Show Tasks List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Updated Tasks ${values[1]}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      Text(
                        'Sent Tasks ${values[0]}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 3,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Remaining Tasks ${values[3]}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(width: 30),
                      Text(
                        'Marked Tasks ${values[4]}',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 6, 2, 255)),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 3,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Late Tasks ${values[2]}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              Center(
                child: TasksCircularChart(
                  values: values,
                  colors: colors,
                ),
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: ordersStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Tasks found.'));
                  } else {
                    List<Map<String, dynamic>> orders = snapshot.data!;
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SendTask(task: orders[index]),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            color:
                                getColorBasedOnStatus(orders[index]['status']),
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(
                                orders[index]['description'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                orders[index]['submissionDeadline'] != null
                                    ? (orders[index]['submissionDeadline']
                                            as Timestamp)
                                        .toDate()
                                        .toString()
                                    : '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
    double radius = 1;
    if (size != null) {
      radius = size.width / 3;
    }
    final Offset center = Offset(size.width / 2, size.height / 2);
    double startAngle = -pi / 2;
    double totalValue = values.fold(0, (sum, value) => sum + value).toDouble();

    for (int i = 0; i < values.length; i++) {
      final double sweepAngle = (values[i] / totalValue) * 2 * pi;
      final paint = Paint()
        ..shader = createGradient(colors[i], center, radius)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius / 2
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      final percentage =
          ((values[i] / totalValue) * 100).toStringAsFixed(1) + '%';
      if (((values[i] / totalValue) * 100) != 0) {
        drawText(
            canvas, percentage, center, radius, startAngle + sweepAngle / 2);
      }

      startAngle += sweepAngle;
    }
  }

  void drawText(
      Canvas canvas, String text, Offset center, double radius, double angle) {
    if (text != null || text.isNotEmpty) {
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final x = center.dx + radius * cos(angle) - textPainter.width / 2;
      final y = center.dy + radius * sin(angle) - textPainter.height / 2;
      if (x.isNaN || y.isNaN) {
      } else {
        final textOffset = Offset(x, y);

        textPainter.paint(canvas, textOffset);
      }
    } else {}
  }

  Shader createGradient(Color color, Offset center, double radius) {
    return RadialGradient(
      colors: [color.withOpacity(0.5), color],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
