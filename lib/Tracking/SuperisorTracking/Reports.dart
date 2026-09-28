import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/SuperisorTracking/ReportDetails.dart';
import 'package:Trainity/controller/ordercontrller/updatestatus.dart';
import 'package:Trainity/controller/trakingController/getReportController.dart';

class Reports extends StatefulWidget {
  final String? studentId;
  final String? studentName;

  const Reports({super.key, this.studentId, this.studentName});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final UpdateStatus _updateStatus = UpdateStatus();
  final GetReportsController _getorderController = GetReportsController();
  late Stream<List<Map<String, dynamic>>> ordersStream;

  @override
  void initState() {
    String id = widget.studentId ?? '';
    ordersStream = _getorderController.getReportStream(id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'List of Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
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
                      onPressed: () {},
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
                  String name = widget.studentName ?? '';
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                          orders[index]['description'] ?? 'No Description'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ReportDetails(report: orders[index]),
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
