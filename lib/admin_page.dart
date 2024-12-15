import 'package:flutter/material.dart';
import 'add_staff.dart';
import 'analytics_page.dart'; // Import the AnalyticsPage class

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        backgroundColor: Colors.purple.shade600, // Set app bar color
      ),
      body: Center(
        child: Column(
          children: [
            Expanded( // Use Expanded to use the full height of the page
              child: FractionallySizedBox( // Wrap with FractionallySizedBox to divide width
                widthFactor: 1, // Set the width factor to 90%
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to add staff member page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddStaffMemberPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Set button color
                  ),
                  child: Text('Add Staff Member',style: TextStyle(color: Colors.black),),
                ),
              ),
            ),
            SizedBox(height: 20), // Add some spacing between the buttons
            Expanded( // Use Expanded to use the full height of the page
              child: FractionallySizedBox( // Wrap with FractionallySizedBox to divide width
                widthFactor: 1, // Set the width factor to 90%
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to analytics page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnalyticsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Set button color
                  ),
                  child: Text('Show Analytics'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
