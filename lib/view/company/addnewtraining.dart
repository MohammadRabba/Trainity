import 'package:Trainity/authentication/widgetofauth.dart';
import 'package:Trainity/controller/oppocontrller/addoppo.dart';
import 'package:Trainity/controller/userscontrollers/getallcontroller.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/matchingSystem/matching.dart';
import 'package:Trainity/model/user_model.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/company/homepagecompany.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

class AddNewTraining extends StatefulWidget {
  const AddNewTraining({super.key});

  @override
  State<AddNewTraining> createState() => _AddPersonState();
}

String selectedLocation = 'Ramallah';

List<Map<String, dynamic>> conditions = [];
String cond = '   ';
String priority = 'high';
String dropdownValue = 'GPA';
TextEditingController valueController = TextEditingController();
TextEditingController nStudentController = TextEditingController();

List<UsersModel> mydata = [];
UsersModel supervisorId = mydata.first;
AddOportinites _addUserControler = AddOportinites();
GetAllController _allController = GetAllController();
TextEditingController namecontroller = TextEditingController();
TextEditingController descriptioncontroller = TextEditingController();
bool _isHiddenPassword = true;
bool isloading = true;
String startDate = "";
String endtDate = "";
DateTime? parsedStartDate;
DateTime? parsedEndDate;

DateTime? firstDate = parsedStartDate;
DateTime? lastDate = parsedEndDate;

class _AddPersonState extends State<AddNewTraining> {
  @override
  void initState() {
    getTerm();
    _allController.getallsupervisor().then((value) {
      mydata = value!;
      setState(() {
        isloading = true;
        supervisorId = mydata.isNotEmpty
            ? mydata.first
            : UsersModel(
                id: '',
                email: '',
                name: '',
                phone: '',
                type: '',
              );
      });
    });
    super.initState();
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

  List<String> selectedItems = [];

  Widget textFormField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    required bool obscureText,
    required Function(String?) validator,
    Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) => validator(value),
      onTap: onTap,
    );
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  List<Map<String, dynamic>> conditions = [];

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
          'Add New Training',
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
                        title: Text(conditions[index]['cond']),
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
                  initialValue: '',
                  firstDate: firstDate ?? DateTime.now(),
                  lastDate: lastDate ?? DateTime.now(),
                  dateLabelText: 'Start Date',
                  onChanged: (value) {
                    startDate = value;
                  },
                  validator: (val) {
                    startDate = val!;
                    return null;
                  },
                  onSaved: (newValue) {
                    startDate = newValue!;
                  },
                ),
                SizedBox(
                  height: height / 50,
                ),
                DateTimePicker(
                  timePickerEntryModeInput: false,
                  initialValue: '',
                  firstDate: firstDate ?? DateTime.now(),
                  lastDate: lastDate ?? DateTime.now(),
                  dateLabelText: 'End Date',
                  onChanged: (value) {
                    endtDate = value;
                  },
                  validator: (val) {
                    endtDate = val!;
                    return null;
                  },
                  onSaved: (newValue) {
                    endtDate = newValue!;
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    return null;
                  },
                ),
                loginbutton(
                  "Add",
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
                      _addUserControler.addOppo(
                        namecontroller.text,
                        descriptioncontroller.text,
                        myid,
                        myname,
                        startDate,
                        endtDate,
                        selectedLocation,
                        nStudentController.text.toString(),
                        "0",
                        supervisorId.id.toString(),
                        conditions,
                        selectedItems,
                        context,
                      );
                      List<Map<String, dynamic>> token = [];
                      token = await noteconp.getStudentsToken();
                      for (int i = 0; i < token.length; i++) {
                        print(token[i]);
                        noteconp.sendNote(
                            token[i]['token'],
                            "Opportunity ${namecontroller.text.toString()} Added",
                            "You Can See Opportunity Added",
                            'ShowTraining');
                        noteconp.addNote(
                            token[i]['uid'],
                            'Opportunity ${namecontroller.text.toString()} Added',
                            "You Can See Opportunity Added",
                            'ShowTraining');
                      }
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return const HomePageCompany();
                      }));
                      createnewnote("Your Opportunity Added Sccessfully",
                          "Added Successfully");
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

  @override
  void dispose() {
    super.dispose();
    selectedItems = [];
    selectedLocation = 'Ramallah';
    descriptioncontroller.text = '';
    conditions = [];
    namecontroller.text = '';
    nStudentController.text = '';
    startDate = '';
    endtDate = '';
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
                      const Text('Is Equal or More than'),
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
                          'value': int.tryParse(valueController.text) ?? 60,
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

  bool doesNameExist(String name, List<Map<String, dynamic>> hh) {
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
