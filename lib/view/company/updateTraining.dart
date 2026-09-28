import 'package:Trainity/authentication/widgetofauth.dart';
import 'package:Trainity/controller/orderContrller/updatestatus.dart';
import 'package:Trainity/matchingSystem/matching.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/company/homepagecompany.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

class UpdateTraining extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String? id;
  final String? sDate;
  final List<dynamic>? oldcond;
  final String? nStudent;
  final List<dynamic>? languages;
  const UpdateTraining(
      {Key? key,
      this.oldcond,
      this.data,
      this.sDate,
      this.id,
      this.nStudent,
      this.languages})
      : super(key: key);

  @override
  State<UpdateTraining> createState() => _UpdateTrainingState();
}

DateTime? parsedStartDate;
DateTime? parsedEndDate;

DateTime? firstDate = DateTime.now();
DateTime? lastDate = DateTime.now();

class _UpdateTrainingState extends State<UpdateTraining> {
  String selectedLocation = '';
  UpdateStatus updateStatus = UpdateStatus();

  List<dynamic> conditions = [];
  String cond = '   ';
  String priority = 'high';
  String dropdownValue = 'GPA';
  TextEditingController valueController = TextEditingController();
  TextEditingController nStudentController = TextEditingController();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  bool _isHiddenPassword = true;
  bool isloading = true;
  String sDate = "";
  String endDate = "";
  String nS = '';

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    selectedItems = widget.languages ?? [];
    getSelectedItems();
    conditions = widget.oldcond ?? [];
    namecontroller.text = widget.data?['name'] ?? '';
    descriptioncontroller.text = widget.data?['description'] ?? '';
    selectedLocation = widget.data?['location'] ?? '';
    nStudentController.text = widget.nStudent ?? '0';
    sDate = widget.sDate ?? '';
    endDate = widget.data?['enddate'] ?? '';

    getTerm();
  }

  Map<String, Map<String, List<String>>> categorizedItems = {
    'Front-end': {
      'Languages': ['JavaScript', 'HTML', 'CSS'],
      'Frameworks': ['React', 'Angular', 'Vue'],
    },
    'Back-end': {
      'Languages': ['Node.js', 'Python', 'Ruby', 'Java', 'PHP'],
    },
    'Testing': {
      'Frameworks': ['Selenium', 'Jest', 'JUnit', 'Cypress'],
    },
    'Full-stack': {
      'Languages': ['JavaScript', 'Python', 'Java'],
      'Frameworks': ['MEAN', 'MERN', 'LAMP', 'Django'],
    },
  };

  List<dynamic> selectedItems = [];

  void getSelectedItems() {
    List<String> newSelectedItems = [];

    for (var category in categorizedItems.keys) {
      for (var entry in categorizedItems[category]!.entries) {
        for (var item in entry.value) {
          if (widget.languages?.contains(item) == true) {
            newSelectedItems.add(item);
          }
        }
      }
    }

    setState(() {
      selectedItems = newSelectedItems;
    });
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  void dispose() {
    valueController.dispose();
    nStudentController.dispose();
    namecontroller.dispose();
    descriptioncontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Update Training',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Form(
        key: formstate,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height / 50),
                customCard(
                  namecontroller,
                  "name",
                  TextInputType.name,
                  () {},
                  _isHiddenPassword,
                  (value) {
                    if (value!.isEmpty) {
                      return "name required";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height / 50),
                customCard(
                  descriptioncontroller,
                  "description",
                  TextInputType.text,
                  () {},
                  _isHiddenPassword,
                  (value) {
                    if (value!.isEmpty) {
                      return "description required";
                    }
                    return null;
                  },
                ),
                ExpansionTile(
                  title: const Text(
                    'Select Programming Languages and Frameworks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: categorizedItems.keys.map((category) {
                    return ExpansionTile(
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children:
                          categorizedItems[category]!.entries.map((entry) {
                        return ExpansionTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          children: entry.value.map((item) {
                            return CheckboxListTile(
                              title: Text(item),
                              value: selectedItems.contains(item),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null && value) {
                                    selectedItems.add(item);
                                  } else {
                                    selectedItems.remove(item);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
                const Text(
                  'Location of Opportunity',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedLocation,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLocation = newValue!;
                    });
                  },
                  items: <String>[
                    'Ramallah',
                    'Jenin',
                    'Nablus',
                    'Tolkarem',
                    'BethLahem',
                    'Toubas',
                    'From Home(Remotly)',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addCondition();
                  },
                  child: const Text('Add Condition'),
                ),
                SizedBox(height: height / 50),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: conditions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                            '${conditions[index]['name']} is equal or more than ${conditions[index]['value']}'),
                        onTap: () {
                          setState(() {
                            _editCondition(index);
                          });
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  conditions.removeAt(index);
                                });
                              },
                            ),
                            DropdownButton<String>(
                              value: conditions[index]['priority'],
                              onChanged: (String? newValue) {
                                setState(() {
                                  conditions[index]['priority'] = newValue!;
                                });
                              },
                              items: <String>[
                                'high',
                                'medium',
                                'low'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value.toLowerCase(),
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                DateTimePicker(
                  timePickerEntryModeInput: false,
                  initialValue: sDate,
                  firstDate: firstDate ?? DateTime.now(),
                  lastDate: lastDate ?? DateTime.now(),
                  dateLabelText: 'Start Date',
                  onChanged: (value) {
                    sDate = value;
                  },
                  validator: (val) {
                    sDate = val!;
                  },
                  onSaved: (newValue) {
                    sDate = newValue!;
                  },
                ),
                SizedBox(
                  height: height / 50,
                ),
                DateTimePicker(
                  timePickerEntryModeInput: false,
                  initialValue: endDate,
                  firstDate: parsedStartDate ?? DateTime.now(),
                  lastDate: parsedEndDate ?? DateTime.now(),
                  dateLabelText: 'End Date',
                  onChanged: (value) {
                    endDate = value;
                  },
                  validator: (val) {
                    endDate = val!;
                    return null;
                  },
                  onSaved: (newValue) {
                    endDate = newValue!;
                  },
                ),
                SizedBox(
                  height: height / 50,
                ),
                TextFormField(
                  controller: nStudentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter Number Of Students',
                  ),
                  validator: (value) {
                    nStudentController.text = value!;
                    return null;
                  },
                ),
                SizedBox(height: height / 50),
                loginbutton(
                  "Update",
                  () async {
                    Matching matching = Matching();
                    for (int i = 0; i < conditions.length; i++) {
                      if (conditions[i]['priority'] == 'high') {
                        matching.high = matching.high + 1;
                        matching.checkStatus();
                      } else if (conditions[i]['priority'] == 'medium') {
                        matching.medium = matching.medium + 1;
                        matching.checkStatus();
                      } else {
                        matching.low = matching.low + 1;
                        matching.checkStatus();
                      }
                    }
                    for (int i = 0; i < conditions.length; i++) {
                      if (conditions[i]['priority'] == 'high') {
                        conditions[i]['percentage'] = matching.persentagehigh;
                      } else if (conditions[i]['priority'] == 'medium') {
                        conditions[i]['percentage'] = matching.persentagemeadum;
                      } else {
                        conditions[i]['percentage'] = matching.persentagelow;
                      }
                    }
                    var formdata = formstate.currentState;
                    if (formdata!.validate()) {
                      await FirebaseFirestore.instance
                          .collection('opportinities')
                          .doc(widget.id)
                          .update({
                        'name': namecontroller.text.toString(),
                        'description': descriptioncontroller.text.toString(),
                        'startdate': sDate ?? '',
                        'enddate': endDate ?? '',
                        'nOfstudent': nStudentController.text,
                        'location': selectedLocation,
                        'Languages': selectedItems ?? [],
                        'conditions': conditions
                      });
                      updateStatus.updateTraining(
                          widget.id ?? '',
                          namecontroller.text,
                          descriptioncontroller.text,
                          nStudentController.text);
                      List<Map<String, dynamic>> token = [];
                      token = await noteconp.getStudentsToken();
                      for (int i = 0; i < token.length; i++) {
                        noteconp.sendNote(
                            token[i]['token'],
                            "Opportunity ${namecontroller.text.toString()} Updated",
                            "You Can See Opportunity Updates",
                            'ShowTraining');
                        noteconp.addNote(
                            token[i]['uid'],
                            'Opportunity ${namecontroller.text.toString()} Updated',
                            "You Can See Opportunity Updated",
                            'ShowTraining');
                      }
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.bottomSlide,
                        title: 'Opportunity Updated Succssfully',
                        btnOkOnPress: () {
                          Navigator.pop(context);
                        },
                      ).show();
                      createnewnote("Your Opportunity Updated Sccessfully",
                          "Updeted Successfully");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getTerm() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('term').get();
    for (var doc in querySnapshot.docs) {
      parsedStartDate = DateTime.tryParse(doc['termSD']);
      parsedEndDate = DateTime.tryParse(doc['termED']);

      if (parsedStartDate != null && parsedEndDate != null) {
        firstDate = parsedStartDate;
        lastDate = parsedEndDate;
      }
    }
    print(sDate);
    print(endDate);
  }

  void _addCondition() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Condition'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>[
                      'GPA',
                      'Algorithm',
                      'Structure',
                      'DataBase',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Column(
                    children: [
                      Text('Is Equal or More than'),
                      TextField(
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter value',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    {
                      if (doesNameExist(dropdownValue, conditions)) {
                        updateOrAddCondition();
                      } else {
                        conditions.add({
                          'name': dropdownValue,
                          'priority': 'high',
                          'value': int.tryParse(valueController.text) ?? 0,
                          'cond':
                              '$dropdownValue is equal or more than ${int.tryParse(valueController.text) ?? 0}',
                          'percentage': '0',
                        });
                      }
                      valueController.clear();
                    }
                    Navigator.of(context).pop();
                    print(conditions);
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateOrAddCondition() {
    int newValue = int.tryParse(valueController.text) ?? 0;
    int existingIndex = conditions
        .indexWhere((condition) => condition['name'] == dropdownValue);

    if (existingIndex != -1) {
      conditions[existingIndex]['value'] = newValue;
      conditions[existingIndex]['cond'] =
          '$dropdownValue is equal or more than $newValue';
    } else {
      conditions.add({
        'name': dropdownValue,
        'priority': 'high',
        'value': newValue,
        'cond': '$dropdownValue is equal or more than $newValue',
        'percentage': '0',
      });
    }
  }

  bool doesNameExist(String name, List<dynamic> hh) {
    List<String> names =
        hh.map((map) => map['name'] as String).whereType<String>().toList();
    return names.contains(name);
  }

  void _editCondition(int index) {
    String initialCondition = conditions[index]['name'];
    int initialValue = conditions[index]['value'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Condition'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: initialCondition,
                    onChanged: (String? newValue) {
                      setState(() {
                        initialCondition = newValue!;
                      });
                    },
                    items: <String>[
                      'GPA',
                      'Algorithm',
                      'Structure',
                      'DataBase',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Column(
                    children: [
                      const Text('Is Equal or More than'),
                      TextField(
                        controller: valueController
                          ..text = initialValue.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter value',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    {
                      conditions.add({
                        'name': initialCondition,
                        'priority': 'high',
                        'value': int.tryParse(valueController.text) ?? 0,
                        'cond':
                            '$initialCondition is equal or more than ${int.tryParse(valueController.text) ?? 0}',
                        'percentage': '0',
                      });
                      valueController.clear();
                    }
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
