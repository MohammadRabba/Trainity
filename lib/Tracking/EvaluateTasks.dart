import 'package:Trainity/view/company/homepagecompany.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EvaluateScreen extends StatefulWidget {
  final Map<String, dynamic> taskDetails;

  const EvaluateScreen({super.key, required this.taskDetails});

  @override
  _EvaluateScreenState createState() => _EvaluateScreenState();
}

class _EvaluateScreenState extends State<EvaluateScreen> {
  int? _mark;

  final TextEditingController _markController = TextEditingController();

  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }

  Future<void> _addMark() async {
    if (!mounted) return;

    String markText = _markController.text.trim();
    if (int.parse(markText) > int.parse(widget.taskDetails['from'])) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Mark Shall be Equal or Less Than The Full Mark',
        btnOkOnPress: () {},
      ).show();
    } else if (markText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a mark.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      try {
        int mark = int.parse(markText);

        final docRef = FirebaseFirestore.instance
            .collection('Tracking')
            .doc('taskDetails')
            .collection('TasksResults')
            .doc(widget.taskDetails['doc_id']);

        await docRef.update({
          'mark': mark.toString(),
          'status': '4',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mark added: $mark'),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => HomePageCompany()),
          );
        }

        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HomePageCompany()),
        );
      } catch (e) {
        print('error');
      }
    }
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
          'Evaluate Task',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Details',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'File Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.taskDetails['fileName'] ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Submission Deadline',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        DateFormat('MMMM d, y HH:mm').format(
                            widget.taskDetails['submissionDeadline'].toDate()),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        getstatus(widget.taskDetails['status'].toString()),
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              getcolor(widget.taskDetails['status'].toString()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _launchURL(widget.taskDetails['fileURL']),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.file_download),
                label: const Text(
                  'Download File',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _markController,
                decoration: InputDecoration(
                  labelText: 'Enter Mark',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addMark,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Mark',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Mark: ${widget.taskDetails['mark']} / ${widget.taskDetails['from']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getcolor(String status) {
    if (status == "1") {
      return Colors.green;
    } else if (status == "2") {
      return Colors.blue;
    } else if (status == "3") {
      return Colors.red;
    } else {
      return const Color.fromARGB(255, 34, 4, 234);
    }
  }

  String getstatus(String status) {
    if (status == "1") {
      return "Sent";
    } else if (status == "2") {
      return "Updated";
    } else if (status == "3") {
      return "Late";
    } else {
      return "Marked";
    }
  }

  @override
  void dispose() {
    _markController.dispose();

    super.dispose();
  }
}
