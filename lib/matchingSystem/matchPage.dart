import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/matchingSystem/matching.dart';
import 'package:Trainity/matchingSystem/MatchingDetails.dart';
import 'package:Trainity/matchingSystem/matchStudent.dart';
import 'package:Trainity/view/supervisor/supervisorhomepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowPerson extends StatefulWidget {
  const ShowPerson({super.key});

  @override
  State<ShowPerson> createState() => _ShowPersonState();
}

class _ShowPersonState extends State<ShowPerson> {
  late Stream<List<Map<String, dynamic>>> _studentsStream;
  Map<String, dynamic> oppodata = {};

  @override
  void initState() {
    matchingFunction();
    _studentsStream = getStudentsStream();
    super.initState();
  }

  Stream<List<Map<String, dynamic>>> getStudentsStream() async* {
    try {
      while (true) {
        List<Map<String, dynamic>> students = [];

        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('user')
                .where("type", isEqualTo: "0")
                .where("status", isEqualTo: "0")
                .get();

        students = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'email': doc["email"],
            'name': doc["name"],
            'phone': doc["phone"],
            'type': doc["type"],
            'Matching': doc['Matching'],
          };
        }).toList();

        students = students.map((student) {
          return {
            ...student,
            'Matching': _populateDropdownValues(student),
          };
        }).toList();

        yield students;
        await Future.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      print('Error fetching students: $e');
      yield [];
    }
  }

  List<Map<String, dynamic>> _populateDropdownValues(
      Map<String, dynamic> student) {
    List<dynamic> matchingList = student['Matching'] ?? [];
    List<Map<String, dynamic>> parsedMatchingList = [];

    for (var matching in matchingList) {
      if (matching is Map<String, dynamic>) {
        parsedMatchingList.add(matching);
      }
    }

    parsedMatchingList.sort((a, b) {
      double numA =
          double.tryParse(a['Final'].toString().replaceAll('%', '')) ?? 0;
      double numB =
          double.tryParse(b['Final'].toString().replaceAll('%', '')) ?? 0;
      return numB.compareTo(numA);
    });

    return parsedMatchingList;
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

  Future<List<Map<String, dynamic>>> getAllStudents(int staus) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('user')
              .where('type', isEqualTo: '0')
              .where('status', isEqualTo: staus.toString())
              .get();
      List<Map<String, dynamic>> userList = [];
      for (var doc in querySnapshot.docs) {
        userList.add(doc.data());
      }
      return userList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Matching Page',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          } else {
            List<Map<String, dynamic>> mydata = snapshot.data!;

            return ListView.builder(
              itemCount: mydata.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> value = mydata[index];
                if (value.containsKey('Matching') &&
                    value['Matching'] != null &&
                    value['Matching'].isNotEmpty) {
                  return ListTile(
                    title: Text(value['name'] ?? 'No Name'),
                    subtitle:
                        Text(value['email']?.split('@').first ?? 'No Email'),
                    onTap: () async {
                      Map<String, dynamic> oppodata = {};
                      oppodata = await getAllopp(
                          mydata[index]['Matching'][0]['OpoId']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return matchingDetailsStudent(
                              studentId: value['id'],
                              data: mydata[index],
                              oppo: oppodata,
                            );
                          },
                        ),
                      );
                    },
                    trailing: Text(
                        'Matching:${value['Matching'][0]['Final'] ?? 'No Match'}'),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> oppodata =
                                await getAllopp(value['Matching'][0]['OpoId']);
                            addOrderFromSuperVisor(
                              oppodata['opportunityId'] ?? '',
                              oppodata['company_id'] ?? '',
                              oppodata['name'] ?? '',
                              oppodata['description'] ?? '',
                              value['name'] ?? '',
                              value['id'] ?? '',
                              oppodata['nOfstudent'] ?? '',
                              value['Matching'][0]['Final'].toString() ?? '0%',
                              context,
                            );
                            updateStudent(value['id']);
                            String token =
                                await notesup.getUserToken(value['id']);
                            notesup.sendNote(
                                token,
                                "Your Supervisor Make Order for You",
                                "Your Supervisor Make Your Order!",
                                'OldOrder');
                            notesup.addNote(
                                value['id'],
                                "Your Supervisor Make Order for You",
                                "Your Supervisor Make Your Order!",
                                'OldOrder');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order Added Successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text('Apply'),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                } else {
                  return Text('No Match');
                }
              },
            );
          }
        },
      ),
    );
  }
}

Future<Map<String, dynamic>> getAllopp(String opoId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('opportinities')
            .doc(opoId)
            .get();

    Map<String, dynamic> data = querySnapshot.data() ?? {};
    data['opportunityId'] = opoId;

    print(data);
    return data;
  } catch (e) {
    print('Error: $e');
    return {};
  }
}

Future<void> updateStudent(String id) async {
  CollectionReference order = FirebaseFirestore.instance.collection('user');
  order.doc(id).update({'status': '2'});
}

Future<void> addOrderFromSuperVisor(
    String oppoId,
    String companyId,
    String name,
    String description,
    String studentName,
    String studentId,
    String nOfStudents,
    String matching,
    context) async {
  CollectionReference opportinities =
      FirebaseFirestore.instance.collection('order');
  opportinities.add({
    'oppo_id': oppoId,
    'company_id': companyId,
    'user_id': studentId,
    'name': name,
    'description': description,
    'student_name': studentName,
    'supervisor_id': myid,
    'nOfstudent': nOfStudents,
    'status': "2",
    'Matching': matching,
  });
}
