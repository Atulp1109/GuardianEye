import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'case.dart';
import 'status.dart';
import 'archived_cases.dart';
import 'case_details_page.dart';
import 'case_registration_form.dart';

class StaffCasesPage extends StatefulWidget {
  @override
  _StaffCasesPageState createState() => _StaffCasesPageState();
}

class _StaffCasesPageState extends State<StaffCasesPage> {
  late List<Case> archivedCases = [];
  late List<Case> activeCases = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Cases Page'),
        backgroundColor: Colors.purple[600],
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add your notification logic here
            },
          ),
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: () async {
              final unarchivedCase = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArchivedCases(archivedCases: archivedCases)),
              );
              if (unarchivedCase != null) {
                setState(() {
                  archivedCases.add(unarchivedCase);
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cases').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          List<Case> cases = snapshot.data!.docs.map((doc) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

            // Ensure all values are retrieved as strings and parse accordingly
            String id = doc.id;
            String name = data?['name'] ?? '';
            String ageString = (data?['age'] ?? 0).toString(); // Parse age to string
            String phoneNumber = data?['phone'] ?? '';
            String address = data?['address'] ?? '';
            String statusString = data?['status'] ?? '';
            String imageUrl = (data?['imageUrls'] != null && (data?['imageUrls'] as List).isNotEmpty)
                ? (data?['imageUrls'] as List)[0] // Retrieve the first image URL
                : '';
            // Use an empty string if no image URL is available

            // Parse status string to Status enum
            Status status = getStatusFromString(statusString);

            return Case(
              id: id,
              name: name,
              age: ageString, // Assign age as a string
              phoneNumber: phoneNumber,
              address: address,
              status: status,
              imageUrl: imageUrl, // Assign imageUrl
            );
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Register Cases',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: cases.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                        key: Key(cases[index].id),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          color: Colors.red, // Delete color when sliding left
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Delete', style: TextStyle(color: Colors.white)),
                        ),
                        secondaryBackground: Container(
                          color: Colors.blue, // Archive color when sliding right
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Archive', style: TextStyle(color: Colors.white)),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            _archiveCase(cases[index]); // Archive when swiped right
                          } else if (direction == DismissDirection.startToEnd) {
                            _deleteCase(cases[index]); // Delete when swiped left
                          }
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CaseDetailsPage(caseItem: cases[index]),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image section
                                  cases[index].imageUrl.isNotEmpty
                                      ? CircleAvatar(
                                    backgroundImage: NetworkImage(cases[index].imageUrl),
                                    radius: 30,
                                  )
                                      : Icon(Icons.image), // Placeholder icon if imageUrl is empty
                                  SizedBox(width: 16),
                                  // Case details section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ID: ${cases[index].id}',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Name: ${cases[index].name}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Age: ${cases[index].age}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Status: ${getStatusText(cases[index].status)}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCase = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CaseRegistrationPage()),
          );
          if (newCase != null) {
            await FirebaseFirestore.instance.collection('cases').add({
              'name': newCase.name,
              'age': newCase.age.toString(),
              'phone': newCase.phoneNumber,
              'address': newCase.address,
              'status': newCase.status.toString().split('.').last,
              'imageUrls': newCase.imageUrls, // Use imageUrls instead of imageUrl
            });
          }
        },
        child: Icon(Icons.add_circle_outlined),
        backgroundColor: Colors.purple[600],
      ),
    );
  }
  void _archiveCase(Case caseItem) async {
    try {
      // Add the case to the archived cases collection
      await FirebaseFirestore.instance.collection('archived_cases').doc(caseItem.id).set(caseItem.toMap());

      // Remove the case from the active cases collection
      await FirebaseFirestore.instance.collection('cases').doc(caseItem.id).delete();

      setState(() {
        archivedCases.add(caseItem);
      });
    } catch (e) {
      print('Error archiving case: $e');
    }
  }



  void _deleteCase(Case caseItem) async {
    try {
      await FirebaseFirestore.instance.collection('cases').doc(caseItem.id).delete();
    } catch (e) {
      print('Error deleting case: $e');
    }
  }

  Status getStatusFromString(String statusString) {
    try {
      return Status.values.firstWhere((e) => e.toString().split('.')[1] == statusString);
    } catch (e) {
      print('Error parsing status: $e');
      return Status.inProcess;
    }
  }

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
}
