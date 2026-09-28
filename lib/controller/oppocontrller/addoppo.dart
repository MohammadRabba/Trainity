import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddOportinites {
  Future<void> addOppo(
    String name,
    String description,
    String userId,
    String Companynname,
    String startDate,
    String enddate,
    String location,
    String studentNumber,
    String regesteredN,
    String supervisorId,
    List<Map<String, dynamic>> conditions,
    List<String> languages,
    context,
  ) async {
    CollectionReference opportinities =
        FirebaseFirestore.instance.collection('opportinities');

    opportinities
        .add({
          'company_id': userId,
          'company_name': Companynname,
          'name': name,
          'description': description,
          'startdate': startDate,
          'enddate': enddate,
          'registeredS': regesteredN,
          'location': location,
          'nOfstudent': studentNumber,
          'registeredS': '0',
          'supervisor_id': supervisorId,
          'Languages': languages,
          'conditions': conditions.map((condition) {
            return {
              'name': condition['name'],
              'priority': condition['priority'],
              'value': condition['value'],
              'percentage': condition['percentage'],
            };
          }).toList(),
        })
        .then((_) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Opportunity Adde Successfully"),
                backgroundColor: Colors.green,
              ),
            ))
        .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error Adding Opportunity"),
                backgroundColor: Colors.red,
              ),
            ));
  }
}
