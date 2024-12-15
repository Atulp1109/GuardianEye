import 'package:flutter/material.dart';
import 'package:guardians_eye/case.dart';

import 'status.dart';

class CaseDetailsPage extends StatelessWidget {
  final Case caseItem;

  const CaseDetailsPage({Key? key, required this.caseItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[600],
        title: Text('Case Details'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          Center(
            child: CircleAvatar(
              backgroundImage: NetworkImage(caseItem.imageUrl),
              radius: 90,
            ),
          ),
          SizedBox(height: 20),
          _buildDetailBox('Name', caseItem.name),
          _buildDetailBox('Age', caseItem.age),
          _buildDetailBox('ID', caseItem.id),
          _buildDetailBox('Status', getStatusText(caseItem.status), color: getStatusColor(caseItem.status)),
          _buildDetailBox('Phone Number', caseItem.phoneNumber),
          _buildDetailBox('Address', caseItem.address),
        ],
      ),
    );
  }

  Widget _buildDetailBox(String title, String value, {Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Function to get the text representation of the status
  String getStatusText(Status status) {
    switch (status) {
      case Status.resolved:
        return 'Resolved';
      case Status.unresolved:
        return 'Unresolved';
      case Status.inProcess:
        return 'In Process';
      default:
        return 'Unknown';
    }
  }

  // Function to get the color of the text based on the status
  Color getStatusColor(Status status) {
    switch (status) {
      case Status.resolved:
        return Colors.green;
      case Status.unresolved:
        return Colors.red;
      case Status.inProcess:
        return Colors.yellow;
      default:
        return Colors.black; // Default color in case of unknown status
    }
  }
}
