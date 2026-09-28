import 'package:Trainity/matchingSystem/matchStudent.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/controller/oppocontrller/getalloppo.dart';
import 'package:Trainity/controller/ordercontrller/addorder.dart';
import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/matchingSystem/matching.dart';
import 'package:Trainity/model/oppo_model.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/company/OpportunityDetailsPage.dart';
import 'package:Trainity/view/student/homepage.dart';

class ShowTraining extends StatefulWidget {
  const ShowTraining({super.key});

  @override
  State<ShowTraining> createState() => _ShowTrainingState();
}

class _ShowTrainingState extends State<ShowTraining> {
  final AddOrder _addOrder = AddOrder();
  final GetAllOppoController _allOppoController = GetAllOppoController();
  bool search = false;
  TextEditingController searchController = TextEditingController();
  UpdateStatus updateStatus = UpdateStatus();
  @override
  void initState() {
    super.initState();
    inializingData();
  }

  Future<void> inializingData() async {
    await matchingFunction();
    searchController.addListener(onSearchTextChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchTextChanged);
    searchController.dispose();
    super.dispose();
  }

  void onSearchTextChanged() {
    setState(() {
      search = searchController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Show All Training',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      body: StreamBuilder<List<OppoModel>>(
        stream: search
            ? _allOppoController.getSearchStream(searchController.text)
            : _allOppoController.getOpportunitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<OppoModel>? myOppo = snapshot.data;
            return buildListView(myOppo);
          }
        },
      ),
    );
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

  Future<String> populateDropdownValues(String oppoId) async {
    String pervalue = '';

    QuerySnapshot<Map<String, dynamic>> userDocs = await FirebaseFirestore
        .instance
        .collection('user')
        .where('email', isEqualTo: myemail)
        .get();

    if (userDocs.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> userSnapshot
          in userDocs.docs) {
        Map<String, dynamic>? userData = userSnapshot.data();

        if (userData!.containsKey('Matching') && userData['Matching'] is List) {
          List<dynamic> matchingList = userData['Matching'];

          for (var matchingData in matchingList) {
            if (matchingData is Map<String, dynamic> &&
                matchingData.containsKey('OpoId') &&
                matchingData['OpoId'] == oppoId) {
              pervalue = matchingData['Final'].toString();
              break;
            }
          }
        }
      }
    }

    return pervalue;
  }

  Widget buildListView(List<OppoModel>? myOppo) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search",
              ),
              onChanged: (text) {
                onSearchTextChanged();
              },
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Opportunities :",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 400,
              child: ListView.builder(
                itemCount: myOppo!.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.indigo,
                    child: ListTile(
                      title: Text(
                        myOppo[index].name.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                OpportunityDetailsPage(
                                    opportunity: myOppo[index]),
                          ),
                        );
                      },
                      subtitle: Text(
                        myOppo[index].company_name.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      leading: ElevatedButton(
                        child: Text('Request'),
                        onPressed: () async {
                          final currentContext = context;

                          showDialog(
                            context: currentContext,
                            builder: (context) {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: SizedBox(
                                    height: 70,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                            "Are you sure you want to order?"),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            MaterialButton(
                                              color: Colors.red,
                                              child: const Text("Yes"),
                                              onPressed: () async {
                                                final currentContext = context;

                                                if (await _addOrder.checkOrder(
                                                    myOppo[index].id, myid)) {
                                                  String token =
                                                      await notest.getUserToken(
                                                          myOppo[index]
                                                              .supervisor_id);
                                                  notest.sendNote(
                                                      token,
                                                      "You Have New Orders",
                                                      "Your Student $myname Register in New Order",
                                                      "SuperVisorShowOrder");
                                                  notest.addNote(
                                                      myOppo[index]
                                                          .supervisor_id,
                                                      'Order ${myOppo[index].name} Added',
                                                      "You Can See New Order Added",
                                                      'SuperVisorShowOrder');
                                                  String matching =
                                                      await populateDropdownValues(
                                                          myOppo[index].id);
                                                  _addOrder.addOrder(
                                                      myOppo[index].id,
                                                      myOppo[index].company_id,
                                                      myOppo[index].name,
                                                      myOppo[index].description,
                                                      myOppo[index]
                                                          .supervisor_id,
                                                      myOppo[index].nOfStudent,
                                                      myOppo[index].registeredS,
                                                      matching,
                                                      currentContext);
                                                  updateStatus.updateStudent(
                                                      myid, "1");

                                                  createnewnote(
                                                      "Your Order Added Sccessfully",
                                                      "Added Successfully");
                                                  Navigator.of(currentContext)
                                                      .pop();
                                                } else {
                                                  final currentContext =
                                                      context;

                                                  AwesomeDialog(
                                                    context: currentContext,
                                                    dialogType:
                                                        DialogType.warning,
                                                    animType:
                                                        AnimType.bottomSlide,
                                                    title:
                                                        'You are already registered,or Refused Before',
                                                    btnOkOnPress: () {},
                                                  ).show();
                                                }
                                              },
                                            ),
                                            MaterialButton(
                                              color: Colors.grey,
                                              child: const Text("No"),
                                              onPressed: () {
                                                final currentContext = context;

                                                Navigator.of(currentContext)
                                                    .pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
