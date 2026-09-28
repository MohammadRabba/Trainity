import 'package:flutter/material.dart';
import 'package:Trainity/controller/ordercontrller/getcorder.dart';
import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/model/orderModel.dart';

class MyTrainingOppo extends StatefulWidget {
  const MyTrainingOppo({super.key});

  @override
  State<MyTrainingOppo> createState() => _MyTrainingOppoState();
}

class _MyTrainingOppoState extends State<MyTrainingOppo> {
  final UpdateStatus _updateStatus = UpdateStatus();
  final GetorderController _getorderController = GetorderController();
  late Stream<List<OrderModel>> ordersStream;

  @override
  void initState() {
    ordersStream = _getorderController.getOrdersStudentStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
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
                      trailing: Text(orders[index].description ?? ''),
                      leading: SizedBox(
                        height: 73,
                        width: 80,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 25,
                              child: MaterialButton(
                                color: Colors.green,
                                onPressed: () {
                                  _updateStatus
                                      .updatestatus("2", orders[index].id)
                                      .whenComplete(() {});
                                },
                                child: const Text("accept"),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 25,
                              child: MaterialButton(
                                color: Colors.red,
                                onPressed: () {
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
