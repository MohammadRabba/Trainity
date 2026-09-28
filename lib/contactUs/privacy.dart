import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

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
          'Privacy & Security',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Measures:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPrivacyList(),
            const SizedBox(height: 24),
            const Text(
              'Security Measures:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSecurityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPrivacyListItem(
          'Data Encryption',
          'Use encryption methods to secure sensitive data.',
        ),
        _buildPrivacyListItem(
          'Permission Requests',
          'Ask for permissions only when necessary and explain why they are needed.',
        ),
      ],
    );
  }

  Widget _buildSecurityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSecurityListItem(
          'Authentication and Authorization',
          'Implement strong user authentication methods.',
        ),
        _buildSecurityListItem(
          'Secure Backend',
          'Ensure server-side operations and APIs are secure.',
        ),
      ],
    );
  }

  Widget _buildPrivacyListItem(String title, String description) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
    );
  }

  Widget _buildSecurityListItem(String title, String description) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
    );
  }
}
