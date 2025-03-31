import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardians_eye/authentication/views/login_page.dart';
import 'add_staff.dart';
import 'analytics_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.purple.shade800,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Get.offAll(LoginPage());
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade800.withOpacity(0.8),
              Colors.purple.shade600,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Add Staff Card
              _buildAdminCard(
                context,
                icon: Icons.person_add_alt_1,
                title: "Add Staff Member",
                subtitle: "Register new staff members",
                color: Colors.teal.shade400,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStaffMemberPage()),
                ),
              ),

              SizedBox(height: 30),

              // Analytics Card
              _buildAdminCard(
                context,
                icon: Icons.analytics,
                title: "View Analytics",
                subtitle: "Check system statistics",
                color: Colors.amber.shade600,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnalyticsPage()),
                ),
              ),

              SizedBox(height: 30),

              // Additional Admin Features can be added here
              // _buildAdminCard(
              //   context,
              //   icon: Icons.settings,
              //   title: "Settings",
              //   subtitle: "Configure system preferences",
              //   color: Colors.blueGrey.shade400,
              //   onTap: () {
              //     // Add settings navigation
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
