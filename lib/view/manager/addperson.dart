import 'package:Trainity/component/Color.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/authentication/widgetofauth.dart';
import 'package:Trainity/controller/userscontrollers/addusercontroller.dart';

class AddPerson extends StatefulWidget {
  const AddPerson({super.key});

  @override
  State<AddPerson> createState() => _AddPersonState();
}

List<String> mydata = [
  "company",
  "supervisor",
];
String dropdownValuename = mydata.first;

AddUserControler _addUserControler = AddUserControler();

TextEditingController namecontroller = TextEditingController();
TextEditingController emailcontroller = TextEditingController();
TextEditingController passwordcontroller = TextEditingController();
TextEditingController numbercontroller = TextEditingController();
bool _isHiddenPassword = false;

class _AddPersonState extends State<AddPerson> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: globalcolor,
        elevation: 0,
        title: const Text("add users"),
      ),
      body: Form(
        key: formstate,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height / 70,
                ),
                Image.asset("assets/logo.png", height: 120),
                SizedBox(
                  height: height / 40,
                ),
                const Text(
                  "Add Person",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: height / 50,
                ),
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
                SizedBox(
                  height: height / 50,
                ),
                customCard(
                  numbercontroller,
                  "phone",
                  TextInputType.phone,
                  () {},
                  _isHiddenPassword,
                  (value) {
                    if (value!.isEmpty) {
                      return "phone required";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height / 50,
                ),
                customCard(
                  emailcontroller,
                  "email",
                  TextInputType.emailAddress,
                  () {},
                  _isHiddenPassword,
                  (value) {
                    if (value!.isEmpty) {
                      return "email required";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height / 50,
                ),
                customCard(
                  passwordcontroller,
                  "password",
                  TextInputType.visiblePassword,
                  () {},
                  _isHiddenPassword,
                  (value) {
                    if (value!.isEmpty) {
                      return "password required";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height / 50,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("type:"),
                      DropdownButton<String>(
                        value: dropdownValuename,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? value) {
                          print(dropdownValuename);
                          setState(() {
                            dropdownValuename = value!;
                          });
                        },
                        items: mydata
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                loginbutton(
                  "Add Person",
                  () {
                    var formdata = formstate.currentState;
                    if (formdata!.validate()) {
                      _addUserControler.addUser(
                          namecontroller.text,
                          emailcontroller.text,
                          numbercontroller.text,
                          dropdownValuename,
                          passwordcontroller.text,
                          context);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
