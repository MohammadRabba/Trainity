import 'package:Trainity/view/company/StudentDetails.dart';
import 'package:Trainity/view/supervisor/stuedntDetailsSupervisor.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/controller/ordercontrller/getcorder.dart';
import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/model/orderModel.dart';
import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/notification/notification.dart';

class SuperVisorShowOrder extends StatefulWidget {
  const SuperVisorShowOrder({super.key});

  @override
  State<SuperVisorShowOrder> createState() => _ShowOldTrainerState();
}

class _ShowOldTrainerState extends State<SuperVisorShowOrder> {
  final UpdateStatus _updateStatus = UpdateStatus();
  final GetorderController _getorderController = GetorderController();
  late Stream<List<OrderModel>> ordersStream;
  notification note = notification();
  @override
  void initState() {
    ordersStream = _getorderController.getOrdersSupervisorStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Requests',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
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
              List<OrderModel>? orders = snapshot.data;

              return ListView.builder(
                itemCount: orders!.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(5),
                    color: Colors.grey[200],
                    child: ListTile(
                      title: Text("student : ${orders[index].student_name}"),
                      subtitle: Text(orders[index].name),
                      trailing: Column(
                        children: [
                          Text(orders[index].matching ?? ''),
                          SizedBox(
                            height: 25,
                            child: MaterialButton(
                              color: Colors.blue,
                              onPressed: () async {
                                OrderModel? map = orders[index];

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StudentDetailsSupervisor(
                                            studentId: orders[index].user_id,
                                            data: map),
                                  ),
                                );
                              },
                              child: const Text("Details"),
                            ),
                          ),
                        ],
                      ),
                      textColor: const Color.fromARGB(255, 43, 43, 234),
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
                                  String token = await note
                                      .getUserToken(orders[index].user_id);
                                  note.sendNote(
                                      token,
                                      "You Have Changes of your Order",
                                      "Your Supervisor Accept Your Order",
                                      'OldOrder');
                                  note.addNote(
                                      orders[index].user_id,
                                      "You Have Changes of your Order",
                                      "Your Supervisor Accept Your Order",
                                      'OldOrder');
                                  String tokencomp = await note
                                      .getUserToken(orders[index].company_id);
                                  note.sendNote(
                                      tokencomp,
                                      "You Have New Order",
                                      " Supervisor Make Your Order",
                                      'ShowOrder');
                                  note.addNote(
                                      orders[index].company_id,
                                      "You Have New Order",
                                      " Supervisor Make Your Order",
                                      'ShowOrder');
                                  _updateStatus.updatestatus(
                                      "2", orders[index].id);
                                  _updateStatus.updateStudent(
                                      orders[index].user_id, "2");
                                  createnewnote(
                                      "Your Opportunity Added Sccessfully",
                                      "Added Successfully");

                                  print(
                                      ' id:${orders[index].id},status:${orders[index].status}');
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
                                  String token = await note
                                      .getUserToken(orders[index].user_id);
                                  note.sendNote(
                                      token,
                                      "You Have Changes of your Order",
                                      "Your Supervisor Refuse Your Order",
                                      'OldOrder');
                                  note.addNote(
                                      orders[index].user_id,
                                      "You Have Changes of your Order",
                                      "Your Supervisor Refuse Your Order",
                                      'OldOrder');
                                  _updateStatus
                                      .updatestatus("0", orders[index].id)
                                      .whenComplete(() {});
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
