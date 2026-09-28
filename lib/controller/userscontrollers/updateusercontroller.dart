import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateUser {
  Future updateuser(
    String id,
    String name,
    String phone,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    users
        .doc(user?.uid)
        .update({
          "name": name,
          "phone": phone,
        })
        .then((_) => print("true"))
        .catchError((error) => print(error));
  }
}
