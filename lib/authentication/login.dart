import 'package:Trainity/authentication/ResetPassword.dart';
import 'package:Trainity/authentication/beforBegin.dart';
import 'package:Trainity/authentication/biomitricLogin.dart';
import 'package:Trainity/authentication/singup.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/language/lang_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String emaile = "";
  String passworde = "";
  LoginController user_controller = LoginController();
  bool rememberMe = false;
  bool auth = false;
  bool lang = false;
  final bool _isHiddenPassword = false;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checkForSavedUser();
  }

  void saveUserDataToPrefs(String email, String password, bool check) async {
    if (check == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);
      prefs.setString('password', password);
    }
  }

  void checkForSavedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? emaile = prefs.getString('email');
    String? passworde = prefs.getString('password');
    bool check = prefs.getBool('auth') ?? false;
    bool lange = prefs.getBool('language') ?? false;
    langauge_manager language = Get.find();

    if (emaile != null && passworde != null) {
      setState(() {
        emaile = emaile;
        passworde = passworde;
        emailcontroller.text = emaile!;
        passwordcontroller.text = passworde!;
        rememberMe = true;
        auth = check!;
        lang = lange!;
        if (lang == true) {
          language.Changlang("ar");
        } else {
          language.Changlang("en");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 130, 143, 195),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          },
        ),
      ),
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 130, 143, 195),
              Color.fromARGB(255, 255, 255, 255)
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Form(
            key: formstate,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height / 12),
                const Text(
                  "Training app",
                  style: TextStyle(
                    color: Color.fromARGB(255, 63, 81, 181),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.school,
                  size: 60.0,
                  color: Color.fromARGB(255, 11, 11, 11),
                ),
                SizedBox(height: height / 30),
                const Text(
                  "Login",
                  style: TextStyle(
                    color: Color.fromARGB(255, 63, 81, 181),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height / 50),
                TextFormField(
                  controller: emailcontroller,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {},
                  obscureText: _isHiddenPassword,
                  validator: (value) {
                    bool isEmailValid(String email) {
                      final emailPattern =
                          RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                      return emailPattern.hasMatch(email);
                    }

                    if (!isEmailValid(value ?? '')) {
                      return "Invalid email format";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),
                TextFormField(
                  controller: passwordcontroller,
                  keyboardType: TextInputType.text,
                  onChanged: (_) {},
                  obscureText: _isHiddenPassword,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Password cannot be empty";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                ),
                SizedBox(height: height / 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const ResetPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Forget Password',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: width / 1.4,
                  height: height / 15,
                  child: ElevatedButton(
                    onPressed: () async {
                      var formdata = formstate.currentState;

                      if (formdata?.validate() ?? false) {
                        try {
                          await user_controller.signInWithEmailAndPassword(
                            emailcontroller.text,
                            passwordcontroller.text,
                            context,
                          );
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 63, 81, 181),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (auth == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign In Using Biometrics ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      BiometricAuthentication(
                        authenticate: (context) async {
                          var formdata = formstate.currentState;

                          if (formdata?.validate() ?? false) {
                            try {
                              await user_controller.signInWithEmailAndPassword(
                                emailcontroller.text,
                                passwordcontroller.text,
                                context,
                              );
                            } catch (e) {
                              print(e);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Remember Me?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Checkbox(
                      value: rememberMe,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            rememberMe = value;
                          });
                          saveUserDataToPrefs(
                            emailcontroller.text,
                            passwordcontroller.text,
                            rememberMe,
                          );
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Need An Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const SignUpPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color.fromARGB(255, 63, 81, 181),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
