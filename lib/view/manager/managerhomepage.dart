import 'package:Trainity/component/Color.dart';
import 'package:Trainity/controller/usersControllers/logincontroller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Trainity/view/manager/addperson.dart';
import 'package:Trainity/view/manager/draweradmin.dart';
import 'package:Trainity/view/manager/editperson.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _HomePageState();
}

late String admin;
bool isloading = false;
List<Widget> buttonpages = [const AddPerson(), const EditPerson()];
List<String> buttontitle = ["add person", "update person"];
List<Icon> buttonicon = [
  const Icon(Icons.add),
  const Icon(Icons.edit),
];

class _HomePageState extends State<ManagerHomePage> {
  @override
  void initState() {
    getadmin().whenComplete(() {
      setState(() {
        isloading = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: const AppDrawerAdmin(),
      appBar: AppBar(
        title: FutureBuilder<User?>(
            future: FirebaseAuth.instance.authStateChanges().first,
            builder: (context, snapshot) {
              return Text('Welcome $myname',
                  style: const TextStyle(color: Colors.white));
            }),
      ),
      body: isloading
          ? Container(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: height / 30,
                    ),
                    const Text(
                      "Training app",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height: 200, child: Image.asset("assets/logo.png")),
                    SizedBox(
                      height: height / 40,
                    ),
                    SizedBox(
                      height: 400,
                      child: GridView.builder(
                        itemCount: 2,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 125,
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                              padding: const EdgeInsets.all(5),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) {
                                    return buttonpages[index];
                                  }));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: globalcolor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        buttontitle[index],
                                        style: const TextStyle(fontSize: 9),
                                      ),
                                      buttonicon[index],
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const CircularProgressIndicator(),
    );
  }

  getadmin() async {
    final prefs = await SharedPreferences.getInstance();
    const keyAdmin = 'admin';
    final valueadmin = prefs.get(keyAdmin);
    print(valueadmin.toString());
    admin = valueadmin.toString();
  }
}
