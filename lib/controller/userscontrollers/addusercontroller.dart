import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserControler {
  Future<void> addUser(String name, String email, String phone, String type,
      String password, context) async {
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    users
        .add({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'type': type.toString() == "company" ? "1" : "2",
          'unvirsty_id': "#####"
        })
        .then((value) => AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              title: 'user added succssfully',
              btnOkOnPress: () {},
            )..show())
        .catchError((error) => AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'user didnt add',
              btnOkOnPress: () {},
            )..show());
  }
}
