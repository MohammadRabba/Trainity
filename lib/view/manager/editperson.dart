import 'package:Trainity/component/Color.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/authentication/widgetofauth.dart';
import 'package:Trainity/controller/userscontrollers/deleteusercontroller.dart';
import 'package:Trainity/controller/userscontrollers/getallcontroller.dart';
import 'package:Trainity/controller/userscontrollers/updateusercontroller.dart';
import 'package:Trainity/model/user_model.dart';

class EditPerson extends StatefulWidget {
  const EditPerson({
    super.key,
  });

  @override
  State<EditPerson> createState() => _EditPersonState();
}

UpdateUser _updateUser = UpdateUser();

DeleteUser _deleteUser = DeleteUser();

GetAllController _allController = GetAllController();
bool _isHiddenPassword = false;
TextEditingController namecontroller = TextEditingController();
TextEditingController numbercontroller = TextEditingController();

class _EditPersonState extends State<EditPerson> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  bool isloading = false;
  late List<UsersModel> myusers;
  @override
  void initState() {
    _allController.getall().then((value) {
      myusers = value!;
      setState(() {
        isloading = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: globalcolor,
        elevation: 0,
        title: const Text("update users"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              isloading
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      height: height - 150,
                      child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return (myusers[index].type.toString() == "1" ||
                                  myusers[index].type.toString() == "2")
                              ? const Divider(
                                  color: Colors.black,
                                  height: 3,
                                )
                              : const SizedBox();
                        },
                        itemCount: myusers.length,
                        itemBuilder: (context, index) {
                          return (myusers[index].type.toString() == "1" ||
                                  myusers[index].type.toString() == "2")
                              ? InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    width: width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      content: Form(
                                                        key: formstate,
                                                        child: SizedBox(
                                                          height: 200,
                                                          child: Column(
                                                            children: [
                                                              customCard(
                                                                namecontroller,
                                                                "phone",
                                                                TextInputType
                                                                    .phone,
                                                                () {},
                                                                _isHiddenPassword,
                                                                (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return "phone required";
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    height / 50,
                                                              ),
                                                              customCard(
                                                                numbercontroller,
                                                                "phone",
                                                                TextInputType
                                                                    .phone,
                                                                () {},
                                                                _isHiddenPassword,
                                                                (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return "phone required";
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    height / 50,
                                                              ),
                                                              loginbutton(
                                                                "update",
                                                                () {
                                                                  var formdata =
                                                                      formstate
                                                                          .currentState;
                                                                  if (formdata!
                                                                      .validate()) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    setState(
                                                                        () {
                                                                      isloading =
                                                                          false;
                                                                    });
                                                                    _updateUser
                                                                        .updateuser(
                                                                      myusers[index]
                                                                          .id,
                                                                      namecontroller
                                                                          .text,
                                                                      numbercontroller
                                                                          .text,
                                                                    );
                                                                    _allController
                                                                        .getall()
                                                                        .then(
                                                                            (value) {
                                                                      myusers =
                                                                          value!;
                                                                      setState(
                                                                          () {
                                                                        isloading =
                                                                            true;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            )),
                                        SizedBox(
                                            height: 50,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      content: SizedBox(
                                                        height: 100,
                                                        child: Column(
                                                          children: [
                                                            const Text(
                                                                "are you sure you want to delete this user"),
                                                            MaterialButton(
                                                              color: Colors.red,
                                                              child: const Text(
                                                                  "yes"),
                                                              onPressed: () {
                                                                _deleteUser
                                                                    .deleteuser(
                                                                        myusers[index]
                                                                            .id)
                                                                    .then(
                                                                        (value) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  setState(() {
                                                                    isloading =
                                                                        false;
                                                                  });
                                                                  _allController
                                                                      .getall()
                                                                      .then(
                                                                          (value) {
                                                                    myusers =
                                                                        value!;
                                                                    setState(
                                                                        () {
                                                                      isloading =
                                                                          true;
                                                                    });
                                                                  });
                                                                });
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            )),
                                        const SizedBox(
                                          width: 70,
                                        ),
                                        Column(
                                          children: [
                                            Text(myusers[index].name),
                                            Text(
                                              myusers[index].email,
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            ),
                                            Text(myusers[index]
                                                        .type
                                                        .toString() ==
                                                    "1"
                                                ? "company"
                                                : "super visor"),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
                    )
                  : const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
