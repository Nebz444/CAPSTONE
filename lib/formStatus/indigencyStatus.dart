import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IndigencyStatusPage extends StatefulWidget {
  final int userId;

  IndigencyStatusPage({required this.userId});

  @override
  _IndigencyStatusPageState createState() => _IndigencyStatusPageState();
}

class _IndigencyStatusPageState extends State<IndigencyStatusPage> {
  List<dynamic> indigencyRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIndigencyRequests();
  }

  Future<void> fetchIndigencyRequests() async {
    final url = Uri.parse('https://manibaugparalaya.com/API/getIndigency.php?user_id=${widget.userId}');

    try {
      print("Fetching Indigency data for user_id: ${widget.userId}");
      final response = await http.get(url);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded API Response: ${json.encode(data)}");

        if (data is Map && data.containsKey("message")) {
          print("API Message: ${data["message"]}");
          setState(() {
            indigencyRequests = [];
            isLoading = false;
          });
        } else {
          setState(() {
            indigencyRequests = data;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load Indigency requests");
      }
    } catch (error) {
      print("Error fetching Indigency requests: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068),
      appBar: AppBar(
        title: const Text('Indigency Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : indigencyRequests.isEmpty
            ? const Center(child: Text("No Indigency requests found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: indigencyRequests.length,
          itemBuilder: (context, index) {
            return _buildIndigencyEntry(indigencyRequests[index]);
          },
        ),
      ),
    );
  }

  Widget _buildIndigencyEntry(dynamic request) {
    // Handle potential null values
    String managerName = request['managerName'] ?? 'Unknown';
    String patientName = request['patientName'] ?? 'Unknown';
    String purpose = request['purpose'] ?? 'N/A';
    String status = request['status'] ?? 'Pending';
    String dateRequested = request['created_at'] ?? 'N/A';

    // Define status color based on status value
    Color statusColor = status == 'Accepted' ? Colors.green : (status == 'Pending' ? Colors.orange : Colors.red);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
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
                  status.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text("Manager: $managerName", style: const TextStyle(color: Colors.black)),
                Text("Patient: $patientName", style: const TextStyle(color: Colors.black)),
                Text("Purpose: $purpose", style: const TextStyle(color: Colors.black)),
                Text("Date: $dateRequested", style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
