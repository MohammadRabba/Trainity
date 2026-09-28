import 'package:Trainity/component/Settings.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/authentication/login.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/view/student/CVSystem/maincvpage.dart';
import 'package:Trainity/view/student/studentupdateProfile.dart';

String id = '';

class AppDrawerStudent extends StatelessWidget {
  const AppDrawerStudent({super.key, Key? key2});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 250,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  myphoto != ""
                      ? ClipOval(
                          child: Image.network(
                            myphoto,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("assets/default.png"),
                        ),
                  SizedBox(height: 10),
                  Text(
                    myname,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blue),
            title: Text("My CV", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MainCvPage()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blue),
            title:
                Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.blue),
            title: Text("Update Profile",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const StudentProfilePage()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.blue),
            title:
                Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
