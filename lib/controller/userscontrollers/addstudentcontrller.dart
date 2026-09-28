import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentControler {
  Future<void> addStudnet(String name, String email, String phone,
      String unvirstyId, context) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('student');
    users
        .add({
          'name': name,
          'email': email,
          'phone': phone,
          'unvirsty_id': unvirstyId,
        })
        .then((value) => AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              title: 'Student added succssfully',
              btnOkOnPress: () {},
            )..show())
        .catchError((error) => AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Student didnt add',
              btnOkOnPress: () {},
            )..show());
  }
}
