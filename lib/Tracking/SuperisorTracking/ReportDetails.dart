import 'dart:io';
import 'dart:typed_data';

import 'package:Trainity/notification/createnote.dart';
import 'package:Trainity/view/supervisor/supervisorhomepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetails extends StatefulWidget {
  final Map<String, dynamic>? report;

  const ReportDetails({super.key, required this.report});

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  String comment = '';
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
  }

  Future<void> addCommentTask(BuildContext context, String comment) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tracking')
          .doc('reportkDetails')
          .collection('Reports')
          .doc(widget.report!['id'])
          .update({
        'Supercomment': comment,
      });

      _showSuccessMessage(context);
    } catch (e) {
      print('Error saving task: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }

  Future<void> downloadReport(String fileName) async {
    try {
      Reference storageReference = _storage.ref('Reports/$fileName');
      Uint8List? fileBytes = await storageReference.getData();

      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/$fileName';

      File file = File(filePath);
      await file.writeAsBytes(fileBytes!);
      String url = await storageReference.getDownloadURL();
      _launchURL(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report downloaded to $filePath'),
          backgroundColor: Colors.green,
        ),
      );
      createnewnote('Downloaded Complete', ' Report downloaded to $filePath');
    } catch (e) {
      print('Error downloading assignment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error downloading Report'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Report',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Description:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.report?['description'].isNotEmpty
                          ? widget.report!['description']
                          : 'No description provided',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: const Text(
                  'Download Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  widget.report?['fileName'].isNotEmpty
                      ? widget.report!['fileName']
                      : 'No File Available',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.file_download),
                  color: Colors.blue,
                  onPressed: () {
                    if (widget.report?['fileName'] != '') {
                      downloadReport(widget.report?['fileName']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No File to Download'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Supervisor Comment:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.report!['Supercomment'] ?? 'No Comment',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comments',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.report?['comment'].isNotEmpty
                          ? widget.report!['comment']
                          : 'No Comments',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mentor Comment',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.report?['mentor_comment'].isNotEmpty
                          ? widget.report!['mentor_comment']
                          : 'No Comments',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Add Your Comment',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  addCommentTask(context, _commentController.text);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SuperVisorHomePage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter a comment'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Add Comment',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
