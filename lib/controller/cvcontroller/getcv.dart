import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/model/CVModel.dart';

class GetCVController {
  getCV() async {
    CVModel? cv;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(myid)
        .collection('CV')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        cv = CVModel(perference: doc["pereferences"], cvFile: doc["cv"]);
      }
    });
    return cv;
  }

  checkCV() async {
    bool isexist = false;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(myid)
        .collection("CV")
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        isexist = true;
      }
    });
    return isexist;
  }
}
