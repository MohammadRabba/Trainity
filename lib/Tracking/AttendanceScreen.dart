import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  final List<String> students;
  final String oppoId;

  const AttendanceScreen(
      {super.key, required this.students, required this.oppoId});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _attendanceTaken = false;
  late DateTime _currentDate;
  Map<String, bool> _attendanceMap = {};
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _filteredStudents = List.from(widget.students);
    _searchController.addListener(_filterStudents);

    _initializeAttendanceMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = widget.students.where((student) {
        return student.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _initializeAttendanceMap() {
    _attendanceMap = {
      for (var student in widget.students) student.split('|')[1]: false
    };
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      final currentDateTimestamp =
          DateTime(_currentDate.year, _currentDate.month, _currentDate.day);

      final attendanceSnapshot = await FirebaseFirestore.instance
          .collection('Tracking')
          .doc('attendanceDetails')
          .collection(widget.oppoId)
          .doc(currentDateTimestamp.toString())
          .get();

      if (attendanceSnapshot.exists) {
        setState(() {
          _attendanceTaken = true;
          _attendanceMap.clear();
          Map<String, dynamic> attendanceData =
              attendanceSnapshot.data() as Map<String, dynamic>;
          attendanceData.forEach((key, value) {
            if (value != null && value is bool) {
              _attendanceMap[key] = value;
            }
          });
        });
      }
    } catch (e) {
      print('Error loading attendance: $e');
    }
  }

  Future<void> _saveAttendance() async {
    try {
      final currentDateTimestamp =
          DateTime(_currentDate.year, _currentDate.month, _currentDate.day);

      final attendanceRef = FirebaseFirestore.instance
          .collection('Tracking')
          .doc('attendanceDetails')
          .collection(widget.oppoId);

      await attendanceRef
          .doc(currentDateTimestamp.toString())
          .set(_attendanceMap);

      setState(() {
        _attendanceTaken = true;
      });

      _showSuccessMessage();
    } catch (e) {
      print('Error saving attendance: $e');
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance taken successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _toggleAttendance(String studentId) {
    if (!_attendanceTaken) {
      setState(() {
        _attendanceMap[studentId] = !_attendanceMap[studentId]!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Take Attendance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${_currentDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                _filterStudents();
              },
              style: TextStyle(
                color: Colors.black,
              ),
              // TextField properties...
            ),
            const SizedBox(height: 20),
            if (_attendanceTaken)
              const Text(
                'Attendance for today has been taken.',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            Expanded(
              child: _filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'no students'
                            : ' no students with this name"${_searchController.text}".',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredStudents.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: Text(
                              'Select All',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Checkbox(
                              checkColor: Colors.black,
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (states) => Colors.white,
                              ),
                              value: _isAllSelected(),
                              onChanged: _attendanceTaken
                                  ? null
                                  : (value) {
                                      _toggleAllAttendance(value ?? false);
                                    },
                            ),
                          );
                        } else {
                          String studentInfo = _filteredStudents[index - 1];
                          List<String> splitInfo = studentInfo.split('|');
                          String studentName = splitInfo[0];
                          String studentId = splitInfo[1];

                          return Card(
                            elevation: 5.0,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.indigo,
                                    Colors.deepPurpleAccent
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Checkbox(
                                  checkColor: Colors.black,
                                  fillColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (states) => Colors.white,
                                  ),
                                  value: _attendanceMap[studentId] ?? false,
                                  onChanged: _attendanceTaken
                                      ? null
                                      : (value) {
                                          _toggleAttendance(studentId);
                                        },
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _attendanceTaken
          ? null
          : FloatingActionButton(
              onPressed: _saveAttendance,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.save),
            ),
    );
  }

  bool _isAllSelected() {
    return _filteredStudents.isNotEmpty &&
        _filteredStudents.every((studentInfo) {
          String studentId = studentInfo.split('|')[1];
          return _attendanceMap[studentId] ?? false;
        });
  }

  void _toggleAllAttendance(bool value) {
    for (String studentInfo in _filteredStudents) {
      String studentId = studentInfo.split('|')[1];
      _attendanceMap[studentId] = value;
    }
  }
}
