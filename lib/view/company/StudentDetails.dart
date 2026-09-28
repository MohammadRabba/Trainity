import 'dart:io';
import 'dart:typed_data';

import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/model/orderModel.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/company/homepagecompany.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDetails extends StatefulWidget {
  final OrderModel data;
  final String studentId;
  const StudentDetails({
    super.key,
    required this.studentId,
    required this.data,
  });

  @override
  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  Map<String, dynamic> student = {};
  final UpdateStatus _updateStatus = UpdateStatus();
  bool isloading = false;
  void initState() {
    iniatlize();
    super.initState();
  }

  void iniatlize() async {
    student = await getStudent();
    setState(() {
      isloading = true;
    });
  }

  Future<Map<String, dynamic>> getStudent() async {
    Map<String, dynamic> data = {};
    DocumentSnapshot q = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.studentId)
        .get();
    if (q.exists) {
      data['name'] = q['name'] ?? "";
      data['GPA'] = q['GPA'] ?? "";
      data['email'] = q['email'] ?? "";
      data['phone'] = q['phone'] ?? "";
      data['location'] = q['location'] ?? "";
      data['companyName'] = await getCompanyDetails(widget.data.company_id);
    }

    QuerySnapshot cv = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.studentId)
        .collection('CV')
        .get();

    if (cv.docs.isNotEmpty) {
      data['cv'] = cv.docs.first.get('cv') ?? '';
      data['pereferences'] = cv.docs.first.get('pereferences');
    } else {
      data['cv'] = 'No CV';
      data['pereferences'] = '';
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isloading
          ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Information',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 20),
                        Table(
                          border: TableBorder.all(
                              color: const Color.fromARGB(255, 0, 0, 0)),
                          children: [
                            _buildTableRow('Attribute', 'Value',
                                bold: true,
                                bgColor: Color.fromARGB(255, 189, 181, 226)),
                            _buildTableRow(
                                'Student Name', '${student['name'] ?? ''}',
                                bold: true,
                                bgColor: Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow('Student Email',
                                '${student['email'] ?? 'No Email.'}',
                                bold: true,
                                bgColor:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow(
                                'Student GPA', '${student['GPA'] ?? 'No GPA.'}',
                                bold: true,
                                bgColor: Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow('Student Preferences',
                                '${student['pereferences'] ?? 'No Pereferences.'}',
                                bold: true,
                                bgColor:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow('Opportunity Name',
                                '${widget.data.name ?? 'No Name.'}',
                                bold: true,
                                bgColor:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow('Matching Percentage',
                                '${widget.data.matching ?? ''}',
                                bold: true,
                                bgColor:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow('Company Name',
                                '${student['companyName'][0] ?? ''}',
                                bold: true,
                                bgColor:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow('Company Email',
                                '${student['companyName'][1] ?? ''}',
                                bold: true,
                                bgColor:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow(
                                'Student CV', '${student['cv'] ?? 'No CV.'}',
                                isButton: true,
                                bold: true,
                                bgColor:
                                    const Color.fromARGB(255, 250, 250, 250)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : CircularProgressIndicator(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: () async {
                  if (await _updateStatus.checkTraining(widget.data.oppo_id) ==
                      false) {
                    if (await _updateStatus
                            .checkRegistered(widget.data.oppo_id) ==
                        true) {
                      BuildContext currentContext = context;
                      AwesomeDialog(
                        context: currentContext,
                        dialogType: DialogType.warning,
                        animType: AnimType.bottomSlide,
                        title: 'This Opportunity are Full,Force to register',
                        btnOkOnPress: () async {
                          _updateStatus.updateNOfStudents(
                            widget.data.oppo_id,
                          );
                          _updateStatus.updateNOfStudents(widget.data.oppo_id);
                          String registered = await _updateStatus
                              .getRegistered(widget.data.oppo_id);

                          registered =
                              ((int.tryParse(registered) ?? 1) + 1).toString();

                          String token =
                              await noteconp.getUserToken(widget.data.user_id);

                          if (token != '') {
                            noteconp.sendNote(
                                token,
                                "Your Orders Status have some Changes",
                                "Your Opportunity ${widget.data.name} Accepted",
                                'OldOrder');
                          }

                          _updateStatus.updateNumbersTraining(
                              widget.data.oppo_id, registered);

                          _updateStatus.getList(
                            widget.data.oppo_id,
                            widget.data.user_id,
                          );

                          _updateStatus
                              .updatestatus("3", widget.data.id)
                              .whenComplete(() {});

                          _updateStatus.updateStudentStatus(
                              "3", widget.data.user_id);

                          print('registered new:$registered');

                          _updateStatus
                              .removeStudentsFromOrders(widget.data.user_id);

                          noteconp.addNote(
                              widget.data.user_id,
                              "You Have Changes of your Order",
                              "Your Company Accept Your Order",
                              'OldOrder');
                        },
                      ).show();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Student Added Successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const HomePageCompany();
                          },
                        ),
                      );
                    } else {
                      String registered = await _updateStatus
                          .getRegistered(widget.data.oppo_id);
                      registered =
                          ((int.tryParse(registered) ?? 1) + 1).toString();
                      print('uid: ${widget.data.user_id}');
                      String token =
                          await noteconp.getUserToken(widget.data.user_id);
                      if (token != '') {
                        noteconp.sendNote(
                            token,
                            "Your Orders Status have some Changes",
                            "Your Opportunity ${widget.data.name} Accepted",
                            'OldOrder');
                      }

                      _updateStatus.updateNumbersTraining(
                          widget.data.oppo_id, registered);
                      _updateStatus.getList(
                        widget.data.oppo_id,
                        widget.data.user_id,
                      );

                      _updateStatus
                          .updatestatus("3", widget.data.id)
                          .whenComplete(() {});
                      _updateStatus.updateStudentStatus(
                          "3", widget.data.user_id);
                      print('registered new:$registered');

                      noteconp.addNote(
                          widget.data.user_id,
                          "You Have Changes of your Order",
                          "Your Company Accept Your Order",
                          'OldOrder');
                      createnewnote('Student Accepted',
                          "Student ${widget.data.student_name} Accepted Successfully");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Student Added Successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const HomePageCompany();
                          },
                        ),
                      );
                    }
                  } else {
                    _updateStatus.addTraining(
                        widget.data.oppo_id,
                        widget.data.company_id,
                        widget.data.name,
                        widget.data.description,
                        widget.data.supervisorId,
                        widget.data.nOfstudent,
                        "1",
                        context);
                    _updateStatus.getList(
                        widget.data.oppo_id, widget.data.user_id);

                    String token =
                        await noteconp.getUserToken(widget.data.user_id);
                    noteconp.sendNote(
                        token,
                        "Your Orders Status have some Changes",
                        "Your Opportunity ${widget.data.name} Accepted",
                        'OldOrder');
                    noteconp.addNote(
                        widget.data.user_id,
                        "You Have Changes of your Order",
                        "Your Company Accept Your Order",
                        'OldOrder');
                    _updateStatus
                        .updatestatus("3", widget.data.id)
                        .whenComplete(() {});
                    _updateStatus.updateStudentStatus("3", widget.data.user_id);
                    createnewnote('Student Accepted',
                        "Student ${widget.data.student_name} Accepted Successfully");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Student Added Successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const HomePageCompany();
                        },
                      ),
                    );
                  }
                },
                child: Text(
                  "Accept",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () async {
                  String token =
                      await noteconp.getUserToken(widget.data.user_id);
                  noteconp.sendNote(
                      token,
                      "Your Orders Status have some Changes",
                      "Your Opportunity ${widget.data.name} Refued",
                      'OldOrder');
                  token = await noteconp.getUserToken(widget.data.supervisorId);
                  noteconp.sendNote(
                      token,
                      "Your Orders Status have some Changes",
                      "Your Opportunity ${widget.data.name} Refued",
                      '');
                  _updateStatus
                      .updatestatus("0", widget.data.id)
                      .whenComplete(() {});
                  _updateStatus.updateStudentStatus("0", widget.data.user_id);
                  noteconp.addNote(
                      widget.data.user_id,
                      "You Have Changes of your Order",
                      "Company $myname Refuse Your Order",
                      'OldOrder');
                  noteconp.addNote(
                      widget.data.supervisorId,
                      "You Have Changes of your Student Order",
                      "Your Company $myname Refuse Your Order",
                      '');
                  createnewnote('Student Refused',
                      "Student ${widget.data.student_name} Refused Successfully");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const HomePageCompany();
                      },
                    ),
                  );
                },
                child: Text(
                  "Refuse",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String attribute, String value,
      {bool bold = false, bool isButton = false, Color? bgColor}) {
    return TableRow(
      decoration: BoxDecoration(
        color: bgColor ?? Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      children: [
        TableCell(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Text(
              attribute,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
                color: Colors.indigo,
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: isButton
                ? ElevatedButton(
                    onPressed: () async {
                      if (student['cv'] == 'No CV') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No CV Exist For this Student'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        downloadCVFile(student['cv']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      onPrimary: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 14,
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: Text(value),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<List<String>> getCompanyDetails(String id) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(id).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          String name = userData['name'] ?? '';
          String email = userData['email'] ?? '';

          List<String> studentData = [
            name,
            email,
          ];

          return studentData;
        }
      } else {
        print('Document with ID $id does not exist');
        return [];
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
    return [];
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }

  Future<void> downloadCVFile(String fileName) async {
    try {
      Reference storageReference =
          _storage.ref('CVs/${widget.studentId}/$fileName');
      Uint8List? fileBytes = await storageReference.getData();

      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/$fileName';

      File file = File(filePath);
      await file.writeAsBytes(fileBytes!);
      String url = await storageReference.getDownloadURL();
      _launchURL(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CV downloaded to $filePath'),
          backgroundColor: Colors.green,
        ),
      );
      createnewnote('Downloaded Complete', ' CV downloaded to $filePath');
    } catch (e) {
      print('Error downloading assignment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error downloading assignment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
