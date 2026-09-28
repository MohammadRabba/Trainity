import 'package:Trainity/authentication/login.dart';
import 'package:Trainity/component/Settings.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/view/company/CompanyUpdateProfile.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
                  Text(
                    myemail,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.blue),
            title: Text("Home Page",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
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
                  builder: (context) => const CompanyProfilePage()));
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
