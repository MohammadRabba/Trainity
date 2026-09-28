import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';

class UpdateStatus {
  List<String> lists = [];

  Future updatestatus(String status, String id) async {
    CollectionReference order = FirebaseFirestore.instance.collection('order');
    order.doc(id).update({
      "status": status,
    });
  }

  Future<void> removeOldOrders(String id, String status) async {
    try {
      QuerySnapshot orderQuery = await FirebaseFirestore.instance
          .collection('order')
          .where('user_id', isEqualTo: id)
          .where('status', isEqualTo: status)
          .get();

      for (QueryDocumentSnapshot doc in orderQuery.docs) {
        await doc.reference.delete();
      }
    } catch (error) {}
  }

  Future updateStudentStatus(String status, String id) async {
    CollectionReference order = FirebaseFirestore.instance.collection('user');
    order
        .doc(id)
        .update({
          "status": status,
        })
        .then((_) => print("true"))
        .catchError((error) => print(error));
  }

  Future<void> updateNumbersNRegistered(String id, String studentNumber) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('Training')
        .where('oppo_id', isEqualTo: id)
        .get();

    querySnapshot.docs
        .forEach((DocumentSnapshot<Map<String, dynamic>> document) async {
      await document.reference.update({
        'nOfStudent': ((int.parse(studentNumber)) + 1).toString(),
      }).then((_) {
        print("Update successful");
      }).catchError((error) {
        print("Error updating: $error");
      });
    });
  }

  Future updateNumbersTraining(String id, String studentNumber) async {
    CollectionReference orders =
        FirebaseFirestore.instance.collection('Training');
    orders
        .where('oppo_id', isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var document in querySnapshot.docs) {
        orders
            .doc(document.id)
            .update({
              'registeredS': studentNumber.toString(),
            })
            .then((_) => print(studentNumber))
            .catchError((error) => print("Error updating: $error"));
      }
    }).catchError((error) => print("Error fetching documents: $error"));
  }

  Future<void> addTraining(
      String oppoId,
      String companyId,
      String name,
      String description,
      String supervisorId,
      String nOfStudent,
      String registeredS,
      context) async {
    CollectionReference opportinities =
        FirebaseFirestore.instance.collection('Training');
    opportinities.add({
      'oppo_id': oppoId,
      'company_id': companyId,
      'name': name,
      'description': description,
      'supervisor_id': supervisorId,
      'registeredS': registeredS,
      'nOfStudent': nOfStudent,
    });
  }

  Future<bool> checkTraining(String id) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('Training')
        .where('oppo_id', isEqualTo: id)
        .get();
    if (query.docs.isEmpty) {
      return true;
    }
    return false;
  }

  Future<bool> checkRegistered(String id) async {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('Training')
        .where('oppo_id', isEqualTo: id)
        .get();

    if (query.docs.isNotEmpty) {
      Map<String, dynamic> data = query.docs.first.data();
      String? registeredS = data['registeredS'] as String?;
      String? nOfStudent = data['nOfStudent'].toString() as String?;

      if (registeredS != null &&
          nOfStudent != null &&
          nOfStudent == registeredS) {
        return registeredS == nOfStudent;
      }
    }

    return false;
  }

  Future<String> getRegistered(String id) async {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('Training')
        .where('oppo_id', isEqualTo: id)
        .get();

    if (query.docs.isNotEmpty) {
      Map<String, dynamic> data = query.docs.first.data();
      String registeredS = data['registeredS'] as String;

      return registeredS;
    }

    return '';
  }

  Future<void> updateNOfStudents(String id) async {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('Training')
        .where('oppo_id', isEqualTo: id)
        .get();

    if (query.docs.isNotEmpty) {
      Map<String, dynamic> data = query.docs.first.data();
      String docId = query.docs.first.id;
      String? nOfStudent = data['nOfStudent'] as String?;
      FirebaseFirestore.instance
          .collection('Training')
          .doc(docId)
          .update({'nOfStudent': (int.parse(nOfStudent ?? '') + 1).toString()});
    }
  }

  Future<void> getList(String id, String studentId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Training')
              .where('oppo_id', isEqualTo: id)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            querySnapshot.docs.first;
        if (documentSnapshot.data()?.containsKey('listOfStudents') ?? false) {
          List<dynamic> lists =
              documentSnapshot.data()?['listOfStudents'] ?? [];
          lists.add(studentId);
          await FirebaseFirestore.instance
              .collection('Training')
              .doc(documentSnapshot.id)
              .update({'listOfStudents': lists});
        } else {
          List<String> firstS = [];
          firstS.add(studentId);
          await FirebaseFirestore.instance
              .collection('Training')
              .doc(documentSnapshot.id)
              .update({'listOfStudents': firstS});
        }
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> updateTraining(
      String id, String name, String description, String nStudent) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Training')
              .where('oppo_id', isEqualTo: id)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            querySnapshot.docs.first;
        if (documentSnapshot.data()?.containsKey('listOfStudents') ?? false) {
          Map<String, dynamic> lists = documentSnapshot.data() ?? {};

          lists['nOfStudent'] = nStudent.toString();
          lists['name'] = name;
          lists['description'] = description;
          await FirebaseFirestore.instance
              .collection('Training')
              .doc(documentSnapshot.id)
              .update(lists);
        }
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future removeOrder(String id) async {
    CollectionReference orders =
        FirebaseFirestore.instance.collection('Training');
    orders
        .where('oppo_id', isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var document in querySnapshot.docs) {
        orders.doc(document.id).delete();
      }
    });
  }

  Future<void> removeStudentsFromOrders(String id) async {
    try {
      QuerySnapshot<Map<String, dynamic>> orders = await FirebaseFirestore
          .instance
          .collection('order')
          .where('user_id', isEqualTo: id)
          .where('company_id', isEqualTo: myid)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> order in orders.docs) {
        await FirebaseFirestore.instance
            .collection('order')
            .doc(order.id)
            .delete();
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future updateStudent(String id, String status) async {
    CollectionReference order = FirebaseFirestore.instance.collection('user');
    order.doc(id).update({'status': status});
  }
}
