import 'package:Trainity/model/orderModel.dart';
import 'package:Trainity/view/supervisor/stuedntDetailsSupervisor.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/matchingSystem/MatchPage.dart';
import 'package:Trainity/view/supervisor/SupervisorHomePage.dart';

class matchingDetailsStudent extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> oppo;
  final String studentId;
  const matchingDetailsStudent(
      {super.key,
      required this.studentId,
      required this.data,
      required this.oppo});

  @override
  State<matchingDetailsStudent> createState() => _matchingDetailsStudentState();
}

class _matchingDetailsStudentState extends State<matchingDetailsStudent> {
  UpdateStatus updateStatus = UpdateStatus();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Student ${widget.data['name']}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Student ${widget.data['name']}:',
                  style: const TextStyle(color: Colors.grey, fontSize: 20),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                  height: 800,
                  child: ListView.builder(
                    itemCount: widget.data['Matching'].length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> item =
                          widget.data['Matching'][index];
                      final String percentage = item['Final'].toString();
                      final String name = item['oppoName'].toString();

                      return Card(
                        color: Colors.indigo,
                        child: ListTile(
                          title: Text(
                            'Name: $name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          subtitle: Text(
                            'Percentage: $percentage',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          trailing: Column(
                            children: [
                              SizedBox(
                                height: 25,
                                child: MaterialButton(
                                  color: Colors.blue,
                                  onPressed: () async {
                                    Map<String, dynamic> oppodata = {};
                                    oppodata = await getAllopp(
                                      widget.data['Matching'][index]['OpoId'],
                                    );
                                    oppodata['sname'] = widget.data['name'];

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StudentDetailsSupervisor(
                                          studentId: widget.studentId,
                                          oppoData: oppodata,
                                          persentage: percentage,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          leading: MaterialButton(
                            color: Colors.green,
                            child: Text(
                              "Request",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: SizedBox(
                                      height: 70,
                                      child: Column(
                                        children: [
                                          const Text(
                                              "Are you sure you want to order?"),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              MaterialButton(
                                                color: Colors.green,
                                                child: const Text("Yes"),
                                                onPressed: () async {
                                                  String token = await notesup
                                                      .getUserToken(
                                                          widget.studentId);
                                                  notesup.sendNote(
                                                      token,
                                                      "Your Supervisor Make Order for You",
                                                      "Your Supervisor Make Your Order!",
                                                      'OldOrder');
                                                  notesup.addNote(
                                                      widget.studentId,
                                                      "Your Supervisor Make Order for You",
                                                      "Your Supervisor Make Your Order!",
                                                      'OldOrder');
                                                  Map<String, dynamic>
                                                      oppodata = {};
                                                  oppodata = await getAllopp(
                                                    widget.data['Matching']
                                                        [index]['OpoId'],
                                                  );
                                                  addOrderFromSuperVisor(
                                                    oppodata['opportunityId'],
                                                    oppodata['company_id'],
                                                    oppodata['name'],
                                                    oppodata['description'],
                                                    widget.data['name'],
                                                    widget.data['id'],
                                                    oppodata['nOfstudent'],
                                                    widget.data['Matching'][0]
                                                            ['Final']
                                                        .toString(),
                                                    context,
                                                  );
                                                  updateStatus.updateStudent(
                                                      widget.data['id'], "2");
                                                  AwesomeDialog(
                                                    context: context,
                                                    dialogType:
                                                        DialogType.success,
                                                    animType:
                                                        AnimType.bottomSlide,
                                                    title:
                                                        'User Assigned Success ,Waiting for Company Approvment',
                                                    btnOkOnPress: () {},
                                                  ).show();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return ShowPerson();
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                              MaterialButton(
                                                color: Colors.red,
                                                child: const Text("No"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
