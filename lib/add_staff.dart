import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'staff_management.dart';

class AddStaffMemberPage extends StatefulWidget {
  @override
  _AddStaffMemberPageState createState() => _AddStaffMemberPageState();
}

class _AddStaffMemberPageState extends State<AddStaffMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  bool _showCredentials = false;
  bool _credentialsGenerated = false;
  late List<DocumentSnapshot> _credentials = [];


  void sendEmail(String userEmail,String password) async {
    final Email email = Email(
      body: 'You have been registered as a staff on GuardianEye. Your Password is: $password',
      subject: 'Registration on GuardianEye',
      recipients: ['$userEmail'],
    );
    await FlutterEmailSender.send(email);
  }

  void _addStaffMember() async {
    if (_formKey.currentState!.validate()) {
      String firstName = _nameController.text.trim();
      String lastName = _surnameController.text.trim();
      String email = _emailController.text.trim();
      String phoneNumber = _phoneController.text.trim();
      String password = _generateRandomPassword();

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': 'staff',
          'password': password,
        });

        await FirebaseFirestore.instance.collection('credentials').add({
          'email': email,
          'password': password,
          'created_at': Timestamp.now(),
        });

        sendEmail(_emailController.text.trim(),password);

        _fetchCredentials(email);

        setState(() {
          _credentialsGenerated = true;
        });

        // Clear input fields after adding staff member
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _surnameController.clear();
      } catch (e) {
        print('Error creating user: $e');
      }
    }
  }

  Future<void> _fetchCredentials(String email) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('credentials').where('email', isEqualTo: email).get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _showCredentials = true;
        _credentials = snapshot.docs;
      });
    }
  }

  String _generateRandomPassword() {
    const _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final _random = Random.secure();
    return List.generate(8, (index) => _chars[_random.nextInt(_chars.length)]).join();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _showCredentialsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Credentials'),
          content: _credentialsGenerated && _showCredentials
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var credential in _credentials)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Email: ${credential['email']}'),
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(credential['email']),
                          icon: Icon(Icons.content_copy),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Password: ${credential['password']}'),
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(credential['password']),
                          icon: Icon(Icons.content_copy),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
            ],
          )
              : Text('No credentials available yet.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Staff Member'),
        backgroundColor: Colors.purple.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputBox(
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16.0),
              _buildInputBox(
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16.0),
              _buildInputBox(
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    // Add email validation if needed
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16.0),
              _buildInputBox(
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    // Add phone number validation if needed
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addStaffMember();
                  _showCredentialsDialog();
                },
                child: Text('Add Staff Member',style: TextStyle(color: Colors.white),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StaffManagementPage()),
          );
        },
        child: Icon(Icons.manage_accounts),
        backgroundColor: Colors.purple.shade600,
      ),
    );
  }

  Widget _buildInputBox(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
