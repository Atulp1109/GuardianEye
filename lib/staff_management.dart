import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StaffManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Staff'),
        backgroundColor: Colors.purple.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Members',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var user = snapshot.data!.docs[index];
                        var userData = user.data() as Map<String, dynamic>;

                        // Extract user data
                        String firstName = userData['firstName'] ?? 'N/A';
                        String lastName = userData['lastName'] ?? 'N/A';
                        String email = userData['email'] ?? 'N/A';

                        return Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: $firstName $lastName',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text('Email: $email'),
                                SizedBox(height: 8.0),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Delete staff member from Firestore users
                                    await FirebaseFirestore.instance.collection('users').doc(user.id).delete();

                                    // Delete staff member from Firestore credentials
                                    QuerySnapshot credentialsSnapshot = await FirebaseFirestore.instance.collection('credentials').where('email', isEqualTo: email).get();
                                    credentialsSnapshot.docs.forEach((doc) {
                                      doc.reference.delete();
                                    });

                                    // Delete staff member from Firebase Authentication
                                    String userEmail = userData['email'];
                                    try {
                                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                                        email: userEmail,
                                        password: userData['password'],
                                      );
                                      await FirebaseAuth.instance.currentUser!.delete();
                                      print('User deleted from Firebase Authentication.');
                                    } catch (e) {
                                      print('Error deleting user from Firebase Authentication: $e');
                                    }
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
