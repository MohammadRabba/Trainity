import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/authentication/widgetofauth.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/notification/createnote.dart';

class Addterm extends StatefulWidget {
  const Addterm({super.key});

  @override
  AddtermState createState() => AddtermState();
}

class AddtermState extends State<Addterm> {
  List<Map<String, dynamic>> terms = [];
  bool check = false;
  String term = 'Summer Semester';
  String startdate = '';
  String enddate = '';

  @override
  void initState() {
    terms.clear();
    getAllTerms();

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
          'Enter Your Term',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton<String>(
                value: term,
                onChanged: (String? newValue) {
                  setState(() {
                    term = newValue!;
                  });
                },
                items: <String>[
                  'First Semester',
                  'Second Semester',
                  'Summer Semester',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DateTimePicker(
                type: DateTimePickerType.date,
                dateMask: 'yyyy-MM-dd',
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                dateLabelText: 'Enter Start Date of Chapter',
                onChanged: (value) {
                  setState(() {
                    startdate = value;
                  });
                },
              ),
              const SizedBox(height: 12.0),
              DateTimePicker(
                type: DateTimePickerType.date,
                dateMask: 'yyyy-MM-dd',
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                dateLabelText: 'Enter End Date of Chapter',
                onChanged: (value) {
                  setState(() {
                    enddate = value;
                  });
                },
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: terms.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('${index + 1} ) ${terms[index]['term']}'),
                      onTap: () {
                        setState(() {
                          editterm(index);
                        });
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            removeTerm(terms[index]);
                            terms.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              loginbutton(
                "Add",
                () {
                  if (check == false) {
                    addTerm();
                    createnewnote(
                        "Your Term Added Sccessfully", "Added Successfully");
                    Navigator.of(context).pop();
                  } else {
                    createnewnote("Your Term Updated Sccessfully",
                        "Updeted Successfully");
                    updateTerms(term, startdate, enddate);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateTerms(String tt, String sd, String ed) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('term').get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs[0].id;
        Map<String, dynamic> dataToUpdate = {
          'termSD': startdate,
          'termED': enddate,
          'term': term
        };
        print('data: $dataToUpdate ');
        await FirebaseFirestore.instance
            .collection('term')
            .doc(docId)
            .update(dataToUpdate);
      } else {
        print('No Term:');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void editterm(int termn) {
    String oldSD = terms[termn]['termSD'];
    String oldED = terms[termn]['termED'];
    String oldterm = terms[termn]['term'];
    String sd = oldSD;
    String ed = oldED;
    String tt = oldterm;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Term'),
              content: SizedBox(
                width: 250,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton<String>(
                        value: oldterm,
                        onChanged: (String? newValue) {
                          setState(() {
                            oldterm = newValue!;
                          });
                        },
                        items: <String>[
                          'First Semester',
                          'Second Semester',
                          'Summer Semester',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 150,
                        child: DateTimePicker(
                          type: DateTimePickerType.date,
                          dateMask: 'yyyy-MM-dd',
                          initialValue: oldSD,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          dateLabelText: 'Enter Start Date of Chapter',
                          onChanged: (value) {
                            setState(() {
                              oldSD = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      SizedBox(
                        height: 80,
                        child: DateTimePicker(
                          type: DateTimePickerType.date,
                          dateMask: 'yyyy-MM-dd',
                          initialValue: oldED,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          dateLabelText: 'Enter End Date of Chapter',
                          onChanged: (value) {
                            setState(() {
                              oldED = value;
                            });
                          },
                        ),
                      ),
                      loginbutton(
                        "Update",
                        () {
                          startdate = oldSD;
                          enddate = oldED;
                          term = oldterm;
                          updateTerms(tt, sd, ed);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> removeTerm(Map<String, dynamic> tt) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('term')
        .where('term', isEqualTo: tt['term'])
        .where('termSD', isEqualTo: tt['termSD'])
        .where('termED', isEqualTo: tt['termED'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('term')
            .doc(doc.id)
            .delete();
      }
    }
  }

  void getAllTerms() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('term').get();
      List<Map<String, dynamic>> userList = [];
      if (querySnapshot.docs.isNotEmpty) {
        terms.clear();
        check = true;
        for (var doc in querySnapshot.docs) {
          userList.add(doc.data());
        }
        for (int i = 0; i < userList.length; i++) {
          terms.add(userList[i]);
        }
      } else {
        check = false;
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addTerm() async {
    try {
      await FirebaseFirestore.instance.collection('term').doc().set({
        'termSD': startdate,
        'termED': enddate,
        'term': term,
        'SupervisorId': myid
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'New Term Assyned SuccessFully',
        btnOkOnPress: () {},
      ).show();
      print('New Term Asigned SuccessFully');

      print('No term found :');
    } catch (e) {
      print('Error: $e');
    }
  }
}
