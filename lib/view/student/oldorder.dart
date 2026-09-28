import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/controller/ordercontrller/getcorder.dart';
import 'package:Trainity/model/orderModel.dart';

class OldOrder extends StatefulWidget {
  const OldOrder({super.key});

  @override
  State<OldOrder> createState() => _OldOrderState();
}

class _OldOrderState extends State<OldOrder> {
  final GetorderController _getorderController = GetorderController();
  late Stream<List<OrderModel>> ordersStream;
  bool isloading = false;
  final UpdateStatus _updateStatus = UpdateStatus();

  @override
  void initState() {
    ordersStream = _getorderController.getOrdersStudentStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Old Requests',
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
              List<OrderModel> orders = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.all(5),
                            color: Colors.grey[200],
                            child: ListTile(
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Remove Order'),
                                      content: Text(
                                          'Are you sure you want to Remove This Order?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Remove'),
                                          onPressed: () {
                                            if (orders[index].status == '1') {
                                              _updateStatus.removeOldOrders(
                                                  orders[index].user_id, '1');
                                            } else if (orders[index].status ==
                                                '0') {
                                              _updateStatus.removeOldOrders(
                                                  orders[index].user_id, '0');
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "You Cant Remove this Order"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }

                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              title: Text(
                                  "student : ${orders[index].student_name}"),
                              subtitle: Text(orders[index].name.toString()),
                              trailing:
                                  Text(orders[index].description.toString()),
                              leading: Text(
                                getstatus(orders[index].status.toString()),
                                style: TextStyle(
                                  color:
                                      getcolor(orders[index].status.toString()),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Color getcolor(String status) {
    if (status == "1") {
      return const Color.fromARGB(255, 45, 166, 218);
    } else if (status == "3") {
      return Colors.green;
    } else if (status == "2") {
      return const Color.fromARGB(255, 34, 4, 234);
    } else {
      return Colors.red;
    }
  }

  String getstatus(String status) {
    if (status == "1") {
      return "waiting  for \nSupervisor Accept";
    } else if (status == "2") {
      return "waitiny for \nCompany Accept";
    } else if (status == "3") {
      return "Accepted";
    } else {
      return "refused";
    }
  }
}
