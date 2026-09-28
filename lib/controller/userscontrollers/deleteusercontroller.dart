import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteUser{
  Future deleteuser(String id) async {
     CollectionReference users = FirebaseFirestore.instance.collection('user');
    await users.doc(id).delete().then((_) => true)
    .catchError((error) => false);
  }
}