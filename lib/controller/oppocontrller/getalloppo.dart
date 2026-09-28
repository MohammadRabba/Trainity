import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/model/oppo_model.dart';

class GetAllOppoController {
  final StreamController<List<OppoModel>> _ordersStreamController =
      StreamController<List<OppoModel>>.broadcast();
  final StreamController<List<OppoModel>> _searchedStreamController =
      StreamController<List<OppoModel>>.broadcast();

  Stream<List<OppoModel>> getOpportunitiesStream() {
    _fetchOpportunities();
    return _ordersStreamController.stream;
  }

  Stream<List<OppoModel>> getCompanyOpportunitiesStream() {
    _fetchCompanyOpportunities();
    return _ordersStreamController.stream;
  }

  Stream<List<OppoModel>> getSearchStream(String oppo) {
    _searchOppoStream(oppo);
    return _searchedStreamController.stream;
  }

  void _fetchCompanyOpportunities() {
    FirebaseFirestore.instance
        .collection('opportinities')
        .where('company_id', isEqualTo: myid)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<OppoModel> orders = [];

      for (var doc in querySnapshot.docs) {
        orders.add(_createOppoModelFromDoc(doc));
      }

      _ordersStreamController.add(orders);
    });
  }

  Future<List<OppoModel>> getAllOppo() async {
    List<OppoModel> opportunities = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('opportinities').get();

    for (var doc in querySnapshot.docs) {
      opportunities.add(_createOppoModelFromDoc(doc));
    }

    return opportunities;
  }

  void _fetchOpportunities() {
    FirebaseFirestore.instance
        .collection('opportinities')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<OppoModel> orders = [];

      for (var doc in querySnapshot.docs) {
        orders.add(_createOppoModelFromDoc(doc));
      }

      _ordersStreamController.add(orders);
    });
  }

  void _searchOppoStream(String oppo) {
    FirebaseFirestore.instance
        .collection('opportinities')
        .where('company_id', isEqualTo: myid)
        .where('name', isGreaterThanOrEqualTo: oppo)
        .where('name', isLessThan: '${oppo}z')
        .snapshots()
        .listen((QuerySnapshot nameQuerySnapshot) {
      List<OppoModel> opportunities = [];

      for (var doc in nameQuerySnapshot.docs) {
        opportunities.add(_createOppoModelFromDoc(doc));
      }

      _searchedStreamController.add(opportunities);
    });

    FirebaseFirestore.instance
        .collection('opportinities')
        .where('company_id', isEqualTo: myid)
        .where('company_name', isGreaterThanOrEqualTo: oppo)
        .where('company_name', isLessThan: '${oppo}z')
        .snapshots()
        .listen((QuerySnapshot companyNameQuerySnapshot) {
      List<OppoModel> opportunities = [];

      for (var doc in companyNameQuerySnapshot.docs) {
        opportunities.add(_createOppoModelFromDoc(doc));
      }

      _searchedStreamController.add(opportunities);
    });

    FirebaseFirestore.instance
        .collection('opportinities')
        .where('company_id', isEqualTo: myid)
        .where('description', isGreaterThanOrEqualTo: oppo)
        .where('description', isLessThan: '${oppo}z')
        .snapshots()
        .listen((QuerySnapshot descriptionQuerySnapshot) {
      List<OppoModel> opportunities = [];

      for (var doc in descriptionQuerySnapshot.docs) {
        opportunities.add(_createOppoModelFromDoc(doc));
      }

      _searchedStreamController.add(opportunities);
    });
  }

  OppoModel _createOppoModelFromDoc(DocumentSnapshot doc) {
    return OppoModel(
      id: doc.id,
      company_id: doc['company_id'],
      company_name: doc['company_name'],
      name: doc['description'],
      description: doc['name'],
      supervisor_id: doc['supervisor_id'],
      nOfStudent: doc['nOfstudent'],
      registeredS: doc['registeredS'],
      location: doc['location'],
      languages: doc['Languages'],
      conditions: doc['conditions'],
      startDate: doc['startdate'],
      enddate: doc['enddate'],
    );
  }

  void dispose() {
    _ordersStreamController.close();
    _searchedStreamController.close();
  }
}
