import 'package:flutter/material.dart';
import 'package:Trainity/controller/cvcontroller/getcv.dart';
import 'package:Trainity/view/student/CVSystem/addnewcv.dart';
import 'package:Trainity/view/student/CVSystem/userCV.dart';

class MainCvPage extends StatefulWidget {
  const MainCvPage({super.key});

  @override
  State<MainCvPage> createState() => _MainCvPageState();
}

class _MainCvPageState extends State<MainCvPage> {
  late bool choosekind = false;

  final GetCVController _cvController = GetCVController();

  @override
  void initState() {
    _cvController.checkCV().then((value) {
      print(value);
      setState(() {
        choosekind = value ?? false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            width: width,
            child: choosekind ? const UserCV() : const AddNewCv(),
          ),
        ),
      ),
    );
  }
}
