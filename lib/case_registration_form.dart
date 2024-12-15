import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'case.dart'; // Assuming you have a Case class defined
import 'status.dart';

class CaseRegistrationPage extends StatefulWidget {
  @override
  _CaseRegistrationPageState createState() => _CaseRegistrationPageState();
}

class _CaseRegistrationPageState extends State<CaseRegistrationPage> {
  late List<File> _images = []; // Step 1: Define a list of Files

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;

  _CaseRegistrationPageState() {
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // UI for image selection
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Image.file(_images[index]);
              },
            ),
            ElevatedButton(
              onPressed: _getImage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[500]),
              child: Text('Select Image',style: TextStyle(color: Colors.white),),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Set border color here
                  width: 1.0, // Set border width here
                ),
                borderRadius: BorderRadius.circular(8.0), // Set border radius here
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: InputBorder.none, // Hide the default border of TextFormField
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust content padding
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Set border color here
                  width: 1.0, // Set border width here
                ),
                borderRadius: BorderRadius.circular(8.0), // Set border radius here
              ),
              child: TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: InputBorder.none, // Hide the default border of TextFormField
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust content padding
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Set border color here
                  width: 1.0, // Set border width here
                ),
                borderRadius: BorderRadius.circular(8.0), // Set border radius here
              ),
              child: TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: InputBorder.none, // Hide the default border of TextFormField
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust content padding
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Set border color here
                  width: 1.0, // Set border width here
                ),
                borderRadius: BorderRadius.circular(8.0), // Set border radius here
              ),
              child: TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: InputBorder.none, // Hide the default border of TextFormField
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust content padding
                ),
                maxLines: 3,
              ),
            ),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[900]),
              child: Text('Submit',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        // Ensure the picked file is not null and the path is not empty
        if (pickedFile.path != null && pickedFile.path.isNotEmpty) {
          _images.add(File(pickedFile.path)); // Add selected image to _images list
        }
      });
    }
  }

  Future<void> _submitForm() async {
    // Show loader while submitting the form
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Submitting...'),
            ],
          ),
        );
      },
    );

    // Get values from controllers
    String name = _nameController.text;
    String ageText = _ageController.text;
    int age = int.tryParse(ageText) ?? 0;
    String phoneNumber = _phoneNumberController.text;
    String address = _addressController.text;

    // Check for empty fields and ensure at least one image is selected
    if (name.isEmpty ||
        ageText.isEmpty ||
        phoneNumber.isEmpty ||
        address.isEmpty ||
        _images.isEmpty) {
      Navigator.of(context).pop(); // Close the dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all fields and select at least one image.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Generate a unique ID for the new case
    String id = UniqueKey().toString();

    try {
      List<String> imageUrls = [];

      // Create a folder with the case ID as the folder name
      String folderName = '$id';
      Reference folderRef = FirebaseStorage.instance.ref().child(folderName);

      // Upload each image to the folder
      await Future.forEach(_images, (File image) async {
        String imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg'; // Unique name for each image
        Reference imageRef = folderRef.child(imageName);
        UploadTask uploadTask = imageRef.putFile(image);
        TaskSnapshot storageSnapshot = await uploadTask;
        String downloadUrl = await storageSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      });

      // Store case data in Firestore
      await FirebaseFirestore.instance.collection('cases').add({
        'name': name,
        'age': age.toString(),
        'phone': phoneNumber,
        'address': address,
        'status': Status.inProcess.toString().split('.').last,
        'imageUrls': imageUrls,
      });
      String imageFolder = name + phoneNumber.toString();
      final Uri serverUri = Uri.parse('http://192.168.182.238:5000/download_images');
      final response = await http.post(
        serverUri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': imageFolder,
          'image_urls': imageUrls,
        }),
      );

      if (response.statusCode == 302) {
        print('Data sent to server successfully');
      } else {
        print('Failed to send data to server: ${response.statusCode}');
      }

      // Case data successfully stored in Firestore
      print('Case data stored in Firestore');

      // Close the loading dialog
      Navigator.of(context).pop();

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      print('Error storing case data: $e');

      // Close the loading dialog
      Navigator.of(context).pop();
    }
  }
}
