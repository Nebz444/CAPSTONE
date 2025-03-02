import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportStatusPage extends StatefulWidget {
  final int userId; // Pass the logged-in user ID

  ReportStatusPage({required this.userId});

  @override
  _ReportStatusPageState createState() => _ReportStatusPageState();
}

class _ReportStatusPageState extends State<ReportStatusPage> {
  List<dynamic> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final url = Uri.parse('https://baranguard.shop/API/get_reports.php?user_id=${widget.userId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          reports = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load reports");
      }
    } catch (error) {
      print("Error fetching reports: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068),
      appBar: AppBar(
        title: const Text('Report Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : reports.isEmpty
            ? const Center(child: Text("No reports found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return _buildReportEntry(reports[index]);
          },
        ),
      ),
    );
  }

  Widget _buildReportEntry(dynamic report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Status: ${report['status']}", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Note: ${report['note']}"),
          Text("Date: ${report['created_at']}"),
        ],
      ),
    );
  }
}
