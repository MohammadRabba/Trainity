import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';

class AddOrder {
  Future<bool> checkOrder(String oppoId, String userId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('order')
        .where('user_id', isEqualTo: userId)
        .where('oppo_id', isEqualTo: oppoId)
        .get();

    return query.docs.isEmpty;
  }

  Future<void> addOrder(
    String oppoId,
    String companyId,
    String name,
    String description,
    String supervisorId,
    String nOfStudents,
    String registeredS,
    String mathcing,
    BuildContext context,
  ) async {
    CollectionReference opportunities =
        FirebaseFirestore.instance.collection('order');
    try {
      await opportunities.add({
        'oppo_id': oppoId,
        'company_id': companyId,
        'user_id': myid,
        'status': "1",
        'name': name,
        'description': description,
        'student_name': myname,
        'supervisor_id': supervisorId,
        'nOfstudent': nOfStudents,
        'registeredS': registeredS,
        'Matching': mathcing,
      });
    } catch (error) {}
  }
}
