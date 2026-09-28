import 'dart:io';
import 'dart:typed_data';

import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/matchingSystem/matchPage.dart';
import 'package:Trainity/model/orderModel.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/manager/addperson.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDetailsSupervisor extends StatefulWidget {
  final OrderModel? data;
  final String studentId;
  final String? persentage;
  final Map<String, dynamic>? oppoData;
  const StudentDetailsSupervisor({
    super.key,
    required this.studentId,
    this.data,
    this.persentage,
    this.oppoData,
  });

  @override
  State<StudentDetailsSupervisor> createState() =>
      _StudentDetailsSupervisorState();
}

class _StudentDetailsSupervisorState extends State<StudentDetailsSupervisor> {
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
      data['companyName'] =
          await getCompanyDetails(widget.oppoData!['company_id']);
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
                                '${widget.oppoData!['sname'] ?? 'No Name.'}',
                                bold: true,
                                bgColor:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            _buildTableRow('Matching Percentage',
                                '${widget.persentage ?? ''}',
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
                  String token = await note.getUserToken(widget.studentId);
                  note.sendNote(token, "You Have Changes of your Order",
                      "Your Supervisor Accept Your Order", 'OldOrder');
                  note.addNote(
                      widget.studentId,
                      "You Have Changes of your Order",
                      "Your Supervisor Accept Your Order",
                      'OldOrder');
                  String tokencomp =
                      await note.getUserToken(widget.oppoData!['company_id']);
                  note.sendNote(tokencomp, "You Have New Order",
                      " Supervisor Make Your Order", 'ShowOrder');
                  note.addNote(
                      widget.oppoData!['company_id'],
                      "You Have New Order",
                      " Supervisor Make Your Order",
                      'ShowOrder');
                  _updateStatus.updatestatus("2", widget.studentId);
                  _updateStatus.updateStudent(widget.studentId, "2");
                  addOrderFromSuperVisor(
                    widget.oppoData!['opportunityId'],
                    widget.oppoData!['company_id'],
                    widget.oppoData!['name'],
                    widget.oppoData!['description'],
                    widget.oppoData!['sname'],
                    widget.studentId,
                    widget.oppoData!['nOfstudent'],
                    widget.persentage.toString(),
                    context,
                  );
                  createnewnote("Your Opportunity Added Sccessfully",
                      "Added Successfully");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ShowPerson();
                      },
                    ),
                  );
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

  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }
}
