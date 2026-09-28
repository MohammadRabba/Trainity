import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';
import 'package:Trainity/model/orderModel.dart';

class GetorderController {
  final StreamController<List<OrderModel>> _ordersStreamController =
      StreamController<List<OrderModel>>.broadcast();

  Stream<List<OrderModel>> getOrdersSupervisorStream() {
    _fetchOrders();
    return _ordersStreamController.stream;
  }

  Stream<List<OrderModel>> getOrdersCompanyStream() {
    _fetchCompanyOrders();
    return _ordersStreamController.stream;
  }

  Stream<List<OrderModel>> getOrdersStudentStream() {
    _fetchStudentsOrders();
    return _ordersStreamController.stream;
  }

  void _fetchOrders() {
    FirebaseFirestore.instance
        .collection('order')
        .where('supervisor_id', isEqualTo: myid)
        .where('status', isEqualTo: '1')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<OrderModel> orders = [];

      for (var doc in querySnapshot.docs) {
        orders.add(
          OrderModel(
            id: doc.id,
            company_id: doc['company_id'],
            oppo_id: doc['oppo_id'],
            status: doc['status'],
            user_id: doc['user_id'],
            name: doc['name'],
            description: doc['description'],
            student_name: doc['student_name'],
            supervisorId: doc['supervisor_id'],
            nOfstudent: doc['nOfstudent'],
            matching: doc['Matching'],
          ),
        );
      }
      _ordersStreamController.add(orders);
    });
  }

  void dispose() {
    _ordersStreamController.close();
  }

  void _fetchCompanyOrders() {
    FirebaseFirestore.instance
        .collection('order')
        .where('company_id', isEqualTo: myid.toString())
        .where('status', isEqualTo: '2')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<OrderModel> orders = [];

      for (var doc in querySnapshot.docs) {
        orders.add(
          OrderModel(
            id: doc.id,
            company_id: doc['company_id'],
            oppo_id: doc['oppo_id'],
            status: doc['status'],
            user_id: doc['user_id'],
            name: doc['name'],
            description: doc['description'],
            student_name: doc['student_name'],
            supervisorId: doc['supervisor_id'],
            nOfstudent: doc['nOfstudent'],
            matching: doc['Matching'],
          ),
        );
      }
      _ordersStreamController.add(orders);
    });
  }

  void _fetchStudentsOrders() {
    FirebaseFirestore.instance
        .collection('order')
        .where('user_id', isEqualTo: myid.toString())
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<OrderModel> orders = [];

      for (var doc in querySnapshot.docs) {
        orders.add(
          OrderModel(
            id: doc.id,
            company_id: doc['company_id'],
            oppo_id: doc['oppo_id'],
            status: doc['status'],
            user_id: doc['user_id'],
            name: doc['name'],
            description: doc['description'],
            student_name: doc['student_name'],
            supervisorId: doc['supervisor_id'],
            nOfstudent: doc['nOfstudent'],
            matching: doc['Matching'],
          ),
        );
      }
      _ordersStreamController.add(orders);
    });
  }
}
