import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:flutter/material.dart';

import 'package:Trainity/controller/ordercontrller/getcorder.dart';

import 'package:Trainity/controller/ordercontrller/updatestatus.dart';

import 'package:Trainity/model/orderModel.dart';

import 'package:Trainity/view/company/StudentDetails.dart';

import 'package:Trainity/view/company/homepagecompany.dart';

class ShowOrder extends StatefulWidget {
  const ShowOrder({super.key});

  @override
  State<ShowOrder> createState() => _ShowOrderState();
}

class _ShowOrderState extends State<ShowOrder> {
  final UpdateStatus _updateStatus = UpdateStatus();

  final GetorderController _getorderController = GetorderController();

  late Stream<List<OrderModel>> ordersStream;

  @override
  void initState() {
    ordersStream = _getorderController.getOrdersCompanyStream();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<List<OrderModel>>(
          stream: ordersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No orders found.'));
            } else {
              List<OrderModel> orders = snapshot.data ?? [];

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(5),
                    color: Colors.indigo,
                    child: ListTile(
                      title: Text(
                        "student : ${orders[index].student_name}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      subtitle: Text(
                        orders[index].name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      trailing: Column(
                        children: [
                          Text(
                            orders[index].matching ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                            child: MaterialButton(
                              color: Color.fromARGB(255, 0, 166, 255),
                              onPressed: () async {
                                OrderModel? map = orders[index];

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDetails(
                                        studentId: orders[index].user_id,
                                        data: map),
                                  ),
                                );
                              },
                              child: const Text(
                                "Details",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      textColor: Colors.black,
                      leading: SizedBox(
                        height: 73,
                        width: 80,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 25,
                              child: MaterialButton(
                                color: Colors.green,
                                onPressed: () async {
                                  if (await _updateStatus.checkTraining(
                                          orders[index].oppo_id) ==
                                      false) {
                                    if (await _updateStatus.checkRegistered(
                                            orders[index].oppo_id) ==
                                        true) {
                                      BuildContext currentContext = context;

                                      AwesomeDialog(
                                        context: currentContext,
                                        dialogType: DialogType.warning,
                                        animType: AnimType.bottomSlide,
                                        title:
                                            'This Opportunity are Full,Force to register',
                                        btnOkOnPress: () async {
                                          _updateStatus.updateNOfStudents(
                                              orders[index].oppo_id);
                                          String registered =
                                              await _updateStatus.getRegistered(
                                                  orders[index].oppo_id);

                                          registered =
                                              ((int.tryParse(registered) ?? 1) +
                                                      1)
                                                  .toString();

                                          String token =
                                              await noteconp.getUserToken(
                                                  orders[index].user_id);

                                          if (token != '') {
                                            noteconp.sendNote(
                                                token,
                                                "Your Orders Status have some Changes",
                                                "Your Opportunity ${orders[index].name} Accepted",
                                                'OldOrder');
                                          }

                                          _updateStatus.updateNumbersTraining(
                                              orders[index].oppo_id,
                                              registered);

                                          _updateStatus.getList(
                                            orders[index].oppo_id,
                                            orders[index].user_id,
                                          );

                                          _updateStatus
                                              .updatestatus(
                                                  "3", orders[index].id)
                                              .whenComplete(() {});

                                          _updateStatus.updateStudentStatus(
                                              "3", orders[index].user_id);

                                          print('registered new:$registered');

                                          _updateStatus
                                              .removeStudentsFromOrders(
                                                  orders[index].user_id);

                                          noteconp.addNote(
                                              orders[index].user_id,
                                              "You Have Changes of your Order",
                                              "Your Company Accept Your Order",
                                              'OldOrder');
                                        },
                                      ).show();

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Student Added Successfully"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      String registered = await _updateStatus
                                          .getRegistered(orders[index].oppo_id);

                                      registered =
                                          ((int.tryParse(registered) ?? 1) + 1)
                                              .toString();

                                      String token = await noteconp
                                          .getUserToken(orders[index].user_id);

                                      if (token != '') {
                                        noteconp.sendNote(
                                            token,
                                            "Your Orders Status have some Changes",
                                            "Your Opportunity ${orders[index].name} Accepted",
                                            'OldOrder');
                                      }

                                      _updateStatus.updateNumbersTraining(
                                          orders[index].oppo_id, registered);

                                      _updateStatus.getList(
                                        orders[index].oppo_id,
                                        orders[index].user_id,
                                      );

                                      _updateStatus
                                          .updatestatus("3", orders[index].id)
                                          .whenComplete(() {});

                                      _updateStatus.updateStudentStatus(
                                          "3", orders[index].user_id);

                                      print('registered new:$registered');

                                      _updateStatus.removeStudentsFromOrders(
                                          orders[index].user_id);

                                      noteconp.addNote(
                                          orders[index].user_id,
                                          "You Have Changes of your Order",
                                          "Your Company Accept Your Order",
                                          'OldOrder');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Student Added Successfully"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    _updateStatus.addTraining(
                                        orders[index].oppo_id,
                                        orders[index].company_id,
                                        orders[index].name,
                                        orders[index].description,
                                        orders[index].supervisorId,
                                        orders[index].nOfstudent,
                                        "1",
                                        context);

                                    _updateStatus.getList(orders[index].oppo_id,
                                        orders[index].user_id);

                                    String token = await noteconp
                                        .getUserToken(orders[index].user_id);

                                    noteconp.sendNote(
                                        token,
                                        "Your Orders Status have some Changes",
                                        "Your Opportunity ${orders[index].name} Accepted",
                                        'OldOrder');

                                    noteconp.addNote(
                                        orders[index].user_id,
                                        "You Have Changes of your Order",
                                        "Your Company Accept Your Order",
                                        'OldOrder');

                                    _updateStatus
                                        .updatestatus("3", orders[index].id)
                                        .whenComplete(() {});

                                    _updateStatus.updateStudentStatus(
                                        "3", orders[index].user_id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Student Added Successfully"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                child: const Text("accept"),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 25,
                              child: MaterialButton(
                                color: Colors.red,
                                onPressed: () async {
                                  String token = await noteconp
                                      .getUserToken(orders[index].user_id);

                                  noteconp.sendNote(
                                      token,
                                      "Your Orders Status have some Changes",
                                      "Your Opportunity ${orders[index].name} Refued",
                                      'OldOrder');

                                  token = await noteconp
                                      .getUserToken(orders[index].supervisorId);

                                  noteconp.sendNote(
                                      token,
                                      "Your Orders Status have some Changes",
                                      "Your Opportunity ${orders[index].name} Refued",
                                      '');

                                  _updateStatus
                                      .updatestatus("0", orders[index].id)
                                      .whenComplete(() {});

                                  _updateStatus.updateStudentStatus(
                                      "0", orders[index].user_id);

                                  noteconp.addNote(
                                      orders[index].user_id,
                                      "You Have Changes of your Order",
                                      "Your Supervisor Refuse Your Order",
                                      'OldOrder');

                                  noteconp.addNote(
                                      orders[index].supervisorId,
                                      "You Have Changes of your Order",
                                      "Your Supervisor Refuse Your Order",
                                      'OldOrder');
                                },
                                child: const Text("refuse"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
