import 'package:flutter/material.dart';
import 'package:Trainity/authentication/login.dart';
import 'package:Trainity/view/manager/managerhomepage.dart';

class AppDrawerAdmin extends StatelessWidget {
  const AppDrawerAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Drawer(
      backgroundColor: Colors.white, //rgba(192,189,174,255)
      child: Column(
        children: [
          SizedBox(
            height: height / 15,
          ),
          SizedBox(
            height: height / 7,
            width: width / 3,
            child: SizedBox.fromSize(
              size: const Size.fromRadius(100),
              child: Image.asset("assets/logo.png", fit: BoxFit.fitWidth),
            ),
          ),
          // Container(
          //   height: 100,
          //   child: Image.asset("assets/logo2.PNG",width: width/2)),
          SizedBox(
            height: height / 80,
          ),
          Container(
            width: width / 1.5,
            height: height / 15,
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const ManagerHomePage()),
                    (Route<dynamic> route) => false);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.home,
                    color: Colors.blue,
                    size: 30,
                  ),
                  Text(
                    "Home Page",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: height / 80,
          ),

          Container(
            width: width / 1.5,
            height: height / 15,
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.blue,
                    size: 30,
                  ),
                  Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: height / 80,
          ),
        ],
      ),
    );
  }
}
