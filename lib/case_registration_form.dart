import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guardians_eye/services/cloudinary_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class CaseRegistrationPage extends StatefulWidget {
  const CaseRegistrationPage({super.key});

  @override
  _CaseRegistrationPageState createState() => _CaseRegistrationPageState();
}

class _CaseRegistrationPageState extends State<CaseRegistrationPage> {
  final List<File> _images = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    // Validate form
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please fill all fields and select at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload images to Cloudinary
      final imageUrls = await CloudinaryService.uploadImages(_images);

      // Save case data to Firestore
      await FirebaseFirestore.instance.collection('cases').add({
        'name': _nameController.text,
        'age': _ageController.text,
        'phone': _phoneNumberController.text,
        'address': _addressController.text,
        'status': 'inProcess',
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Case registered successfully!')),
      );

      final response = await http.post(
        Uri.parse("http://192.168.0.107:3000/register_case"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'phone': _phoneNumberController.text,
          'image_urls': imageUrls,
        }),
      );
      // Show success message
      if (response.statusCode == 200) {
        print('Case registered successfully on server');
      } else {
        print('Failed to register case on server: ${response.body}');
      }
      // Clear form
      _nameController.clear();
      _ageController.clear();
      _phoneNumberController.clear();
      _addressController.clear();
      setState(() => _images.clear());
    } catch (e, trace) {
      print('Error during case registration: $trace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Case Registration'),
        backgroundColor: Colors.purple[600],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Image grid and form fields remain the same as before
            // ...
            if (_images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) => Image.file(_images[index]),
              ),
            ElevatedButton(
              onPressed: _getImage,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.purple[500]),
              child:
                  Text('Select Image', style: TextStyle(color: Colors.white)),
            ),
            _buildTextField(_nameController, 'Name',
                keyboardType: TextInputType.name),
            _buildTextField(_ageController, 'Age',
                keyboardType: TextInputType.number),
            _buildTextField(_phoneNumberController, 'Phone Number',
                keyboardType: TextInputType.phone),
            _buildTextField(_addressController, 'Address', maxLines: 3),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}
