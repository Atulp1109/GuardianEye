import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<CaseStatusData> _caseData = [];

  @override
  void initState() {
    super.initState();
    _fetchCaseData();
  }

  Future<void> _fetchCaseData() async {
    try {
      // Fetch case data from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('cases').get();

      // Process case data to generate analytics
      List<CaseStatusData> data = [];

      // Count the number of cases for each status
      Map<String, int> statusCounts = {};

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'Unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      });

      // Convert status counts to CaseStatusData objects
      statusCounts.forEach((status, count) {
        data.add(CaseStatusData(status, count));
      });

      setState(() {
        _caseData = data;
      });
    } catch (e) {
      print('Error fetching case data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final series = [
      charts.Series<CaseStatusData, String>(
        id: 'Cases',
        domainFn: (CaseStatusData caseData, _) => caseData.status,
        measureFn: (CaseStatusData caseData, _) => caseData.numberOfCases,
        data: _caseData,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.blue),
      )
    ];

    final chart = charts.BarChart(
      series,
      animate: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
        backgroundColor: Colors.purple.shade600,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cases Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              width: 300,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

class CaseStatusData {
  final String status;
  final int numberOfCases;

  CaseStatusData(this.status, this.numberOfCases);
}
