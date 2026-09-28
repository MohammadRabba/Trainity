import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/ShowReport.dart';
import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/controller/trakingController/getReportController.dart';
import 'package:Trainity/controller/userscontrollers/logincontroller.dart';

class ShowReports extends StatefulWidget {
  const ShowReports({super.key});

  @override
  State<ShowReports> createState() => _ShowReportsState();
}

class _ShowReportsState extends State<ShowReports> {
  final GetReportsController _getorderController = GetReportsController();
  late Stream<List<Map<String, dynamic>>> ordersStream;

  @override
  void initState() {
    ordersStream = _getorderController.getReportStream(myid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: ordersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    ElevatedButton(
                      child: Text('Retry'),
                      onPressed: () {/* Retry logic */},
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Reports Yet.'));
            } else {
              List<Map<String, dynamic>>? orders = snapshot.data;
              return ListView.builder(
                itemCount: orders!.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        myname,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                          orders[index]['description'] ?? 'No Description'),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ReportsScreen(report: orders[index]),
                          ),
                        );
                      },
                      leading: Icon(
                        Icons.account_circle_outlined,
                        color: Colors.blue,
                        size: 40,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
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
