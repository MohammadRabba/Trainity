import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/model/CompanyModel.dart';

class CompaniesListScreen extends StatelessWidget {
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
          'Companys',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<List<CompanyModel>>(
        stream: fetchCompanies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No companies found'));
          } else {
            List<CompanyModel> companies = snapshot.data!;
            return ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                CompanyModel company = companies[index];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    title: Text(company.name ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${company.email ?? 'No Email'}'),
                        const SizedBox(height: 5),
                        Text('Phone: ${company.phone ?? 'No Phone'}'),
                        const SizedBox(height: 5),
                        Text('Location: ${company.location ?? 'No Address'}'),
                      ],
                    ),
                    leading: (company.photo != null && company.photo.isNotEmpty)
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(company.photo))
                        : const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.business, color: Colors.white),
                          ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Stream<List<CompanyModel>> fetchCompanies() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('type', isEqualTo: '1')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var jsonData = doc.data();
        jsonData['id'] = doc.id;
        return CompanyModel.fromJson(jsonData);
      }).toList();
    });
  }
}
