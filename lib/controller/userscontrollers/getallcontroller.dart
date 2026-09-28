import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trainity/model/user_model.dart';

class GetAllController {
  getall() async {
    List<UsersModel> users = [];
    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        users.add(UsersModel(
            email: doc["email"],
            name: doc["name"],
            phone: doc["phone"],
            type: doc["type"],
            id: doc.id));
      }
    });
    return users;
  }

  getallsupervisor() async {
    List<UsersModel> users = [];
    await FirebaseFirestore.instance
        .collection('user')
        .where('type', isEqualTo: "2")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        // print(doc.id);
        users.add(UsersModel(
            email: doc["email"],
            name: doc["name"],
            phone: doc["phone"],
            type: doc["type"],
            id: doc.id));
        // print(doc["email"]);
      }
    });
    return users;
  }
}
