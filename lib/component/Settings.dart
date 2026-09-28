import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Trainity/authentication/login.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/language/lang_controller.dart';
import 'package:Trainity/view/company/drawer.dart';
import 'package:Trainity/view/student/drawerstudent.dart';
import 'package:Trainity/view/supervisor/draweradmisupervisor.dart';

bool checkdark = false;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool check = false;
  bool checkLang = false;
  TextEditingController passwordcontroller = TextEditingController();

  langauge_manager lang = Get.find();
  @override
  void initState() {
    super.initState();
    getSavedSettings();
  }

  void getSavedSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      check = prefs.getBool('auth') ?? false;
    });
  }

  void toggleLanguage(bool newValue) async {
    setState(() {
      checkLang = newValue;
    });
    if (checkLang == true) {
      lang.Changlang("ar");
    } else {
      lang.Changlang("en");
    }
  }

  void toggleBiometrics(bool newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      check = newValue;
    });
    prefs.setBool('auth', newValue);
  }

  Future<void> resetPassword(String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? myemail;
    String oldPass = prefs.getString('password') ?? '';
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: oldPass,
    );

    user
        ?.reauthenticateWithCredential(credential)
        .then((authResult) {})
        .catchError((error) {});
    user?.updatePassword(password).then((_) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Password reset  successfully.',
        btnOkOnPress: () {
          Navigator.of(context).pop();
        },
      ).show();
    }).catchError((error) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Password reset Failed.',
        btnOkOnPress: () {
          Navigator.of(context).pop();
        },
      ).show();
    });
  }

  Future<void> removeUserProfile(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      User? user = FirebaseAuth.instance.currentUser;

      await user?.delete();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: '7'.tr,
        btnOkOnPress: () {},
      ).show();
      print('User profile deleted successfully');
    } catch (error) {
      print('Error deleting user profile: $error');
    }
  }

  Widget getAppDrower() {
    if (status == '0') {
      return AppDrawerStudent();
    } else if (status == '1') {
      return AppDrawer();
    } else if (status == '3') {
      return AppDrawerSuperVisor();
    } else {
      return AppDrawerSuperVisor();
    }
  }

  @override
  Widget build(BuildContext context) {
    var darkModeProvider = Provider.of<DarkModeProvider>(context);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: getAppDrower(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Setting',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(12.0, 5, 12.0, 5),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SwitchListTile(
              title: Text(
                "2".tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              subtitle: Text(
                "2".tr,
                style: TextStyle(
                  color: Colors.indigo.shade400,
                ),
              ),
              value: checkLang,
              onChanged: (newValue) {
                toggleLanguage(newValue);
              },
              secondary: const Icon(
                Icons.language,
                color: Colors.indigo,
              ),
              activeColor: Colors.indigo,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(12.0, 5, 12.0, 5),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SwitchListTile(
              title: Text(
                "4".tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              subtitle: Text(
                "3".tr,
                style: TextStyle(
                  color: Colors.indigo.shade400,
                ),
              ),
              value: check,
              onChanged: (newValue) {
                toggleBiometrics(newValue);
              },
              secondary: const Icon(
                Icons.fingerprint,
                color: Colors.indigo,
              ),
              activeColor: Colors.indigo,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(12.0, 5, 12.0, 5),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SwitchListTile(
              title: Text(
                '6'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              subtitle: Text(
                '5'.tr,
                style: TextStyle(
                  color: Colors.indigo.shade400,
                ),
              ),
              secondary: Icon(
                Icons.nightlight_round,
                color: Colors.indigo,
              ),
              value: checkdark,
              onChanged: (newValue) async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Dark Mode Confirmation'),
                      content: const Text(
                          'Are you sure you want to change the mode? You will need to restart the app.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            setState(() {
                              checkdark = newValue;
                            });
                            darkModeProvider
                                .toggleDarkMode(checkdark)
                                .then((_) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Mode will be changed soon."),
                                        backgroundColor: Colors.green,
                                      ),
                                    ))
                                .catchError((error) =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error Changing Mode"),
                                        backgroundColor: Colors.red,
                                      ),
                                    ));

                            Navigator.of(context).pop();
                          },
                          style:
                              TextButton.styleFrom(primary: Colors.deepPurple),
                        ),
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(primary: Colors.grey),
                        ),
                      ],
                    );
                  },
                );
              },
              activeColor: Colors.indigo,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),

          SizedBox(height: height / 80),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text(
                        'Are you sure you want to delete your profile? This action cannot be undone.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () async {
                          await removeUserProfile(myid);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.delete_outline, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Delete Profile',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
//Text('7'.tr,
          SizedBox(height: height / 80),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Reset Password'),
                    content: TextFormField(
                      controller: passwordcontroller,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password cannot be empty";
                        }
                        return null;
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Confirm'),
                        onPressed: () {
                          resetPassword(passwordcontroller.text);
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
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              minimumSize: Size(width / 1.5, height / 15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.password, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DarkModeProvider extends ChangeNotifier {
  bool get isDarkMode => checkdark;

  Future<void> toggleDarkMode(bool checkdark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', checkdark);
    checkdark = !checkdark;
    notifyListeners();
  }
}
