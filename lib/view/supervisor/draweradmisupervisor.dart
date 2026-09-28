import 'package:Trainity/component/Settings.dart';
import 'package:Trainity/view/supervisor/SupervisorProfile.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/authentication/login.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/view/supervisor/ShowCompanyRegistrations.dart';
import 'package:Trainity/view/supervisor/SupervisorHomePage.dart';
import 'package:Trainity/view/supervisor/UploadFile.dart';
import 'package:Trainity/view/supervisor/addTerm.dart';
import 'package:Trainity/view/supervisor/AssignNewCompany.dart';
import 'package:Trainity/view/supervisor/listOfRegisteredCompanies.dart';
import 'package:Trainity/view/supervisor/listOfRegisteredStudents.dart';

class AppDrawerSuperVisor extends StatelessWidget {
  const AppDrawerSuperVisor({super.key});
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
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SuperVisorHomePage()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.upload, color: Colors.blue),
            title: Text("upload CSV File",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ListFilesInStorage()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add_box_sharp, color: Colors.blue),
            title:
                Text("Add Term", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Addterm()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add, color: Colors.blue),
            title: Text("Assign New Company",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddCompany()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.list, color: Colors.blue),
            title: Text("List of Companies",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CompaniesListScreen()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.list, color: Colors.blue),
            title: Text("List of Students",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => studentListScreen()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.blue),
            title:
                Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const supervisourprofile()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.app_registration, color: Colors.blue),
            title: Text("Company registration requests",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ShowCompanyRegistrations()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blue),
            title:
                Text("Setting", style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
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
