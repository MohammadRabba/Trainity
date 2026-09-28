import 'package:Trainity/model/oppo_model.dart';
import 'package:flutter/material.dart';

class OpportunityDetailsPage extends StatelessWidget {
  final OppoModel opportunity;

  const OpportunityDetailsPage({required this.opportunity});

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
          'Training Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailCard('Company Name', opportunity.company_name),
            _buildDetailCard('Opportunity Name', opportunity.name),
            _buildDetailCard('Description', opportunity.description),
            _buildDetailCard('Number of Students', opportunity.nOfStudent),
            _buildDetailCard('Location', opportunity.location),
            _buildDetailCard('Languages', opportunity.languages),
            _buildDetailCard('Conditions', opportunity.conditions),
            _buildDetailCard('Start Date', opportunity.startDate),
            _buildDetailCard('End Date', opportunity.enddate),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, dynamic value) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.indigo[700]!, Colors.indigo[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              if (value is List)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    value.length,
                    (index) => Text(
                      '- ${value[index]}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
