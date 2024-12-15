import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardians_eye/case.dart';

class ArchivedCases extends StatefulWidget {
  final List<Case> archivedCases;

  ArchivedCases({required this.archivedCases});

  @override
  _ArchivedCasesState createState() => _ArchivedCasesState();
}

class _ArchivedCasesState extends State<ArchivedCases> {
  List<Case> _archivedCases = [];
  late List<Case> activeCases = [];


  @override
  void initState() {
    super.initState();
    _archivedCases = widget.archivedCases;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archived Cases'),
        backgroundColor: Colors.purple[600],
      ),
      body: _buildArchivedCasesList(),
    );
  }

  Widget _buildArchivedCasesList() {
    return ListView.builder(
      itemCount: _archivedCases.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                _archivedCases[index].name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'ID: ${_archivedCases[index].id}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.unarchive),
                    onPressed: () {
                      _unarchiveCase(index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteArchivedCase(index);
                    },
                  ),
                ],
              ),
              onTap: () {
                // Handle tapping on archived case
              },
            ),
          ),
        );
      },
    );
  }

  void _unarchiveCase(int index) async {
    try {
      // Retrieve the archived case data
      final caseData = await FirebaseFirestore.instance.collection('archived_cases').doc(_archivedCases[index].id).get();

      // Add the case to the active cases collection with all details
      await FirebaseFirestore.instance.collection('cases').doc(_archivedCases[index].id).set(caseData.data()!);

      // Remove the case from the archived cases collection
      await FirebaseFirestore.instance.collection('archived_cases').doc(_archivedCases[index].id).delete();

      setState(() {
        _archivedCases.removeAt(index);
      });
    } catch (e) {
      print('Error unarchiving case: $e');
    }
  }

  void _deleteArchivedCase(int index) async {
    try {
      // Remove the case from the archived cases collection
      await FirebaseFirestore.instance.collection('archived_cases').doc(_archivedCases[index].id).delete();

      setState(() {
        _archivedCases.removeAt(index);
      });
    } catch (e) {
      print('Error deleting archived case: $e');
    }
  }
}

