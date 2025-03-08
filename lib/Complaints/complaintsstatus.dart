import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ComplaintsStatusPage extends StatefulWidget {
  final int userId;

  ComplaintsStatusPage({required this.userId});

  @override
  _ComplaintsStatusPageState createState() => _ComplaintsStatusPageState();
}

class _ComplaintsStatusPageState extends State<ComplaintsStatusPage> {
  List<dynamic> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    final url = Uri.parse('https://manibaugparalaya.com/API/get_complaints.php?user_id=${widget.userId}');

    try {
      final response = await http.get(url);
      print("Response: ${response.body}"); // Debugging line

      if (response.statusCode == 200) {
        setState(() {
          complaints = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load complaints");
      }
    } catch (error) {
      print("Error fetching complaints: $error");
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068), // New background color
      appBar: AppBar(
        title: const Text('Complaints Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Adjusted padding
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : complaints.isEmpty
            ? const Center(child: Text("No complaints found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            return _buildComplaintsEntry(complaints[index]);
          },
        ),
      ),
    );
  }

  Widget _buildComplaintsEntry(dynamic complaints) {
    Color statusColor = complaints['status'] == 'Accepted' ? Colors.green : Colors.orange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15), // Adjusted padding
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5, right: 8),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaints['status'],
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text("Concern: ${complaints['complaint_type']}", style: const TextStyle(color: Colors.black)),
                Text("Date: ${complaints['created_at']}", style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}