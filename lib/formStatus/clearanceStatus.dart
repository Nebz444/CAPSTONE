import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClearanceStatusPage extends StatefulWidget {
  final int userId;

  ClearanceStatusPage({required this.userId});

  @override
  _ClearanceStatusPageState createState() => _ClearanceStatusPageState();
}

class _ClearanceStatusPageState extends State<ClearanceStatusPage> {
  List<dynamic> clearanceRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClearanceRequests();
  }

  Future<void> fetchClearanceRequests() async {
    final url = Uri.parse('https://manibaugparalaya.com/API/getClearance.php?user_id=${widget.userId}');

    try {
      print("Fetching Clearance data for user_id: ${widget.userId}");
      final response = await http.get(url);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded API Response: ${json.encode(data)}");

        if (data is Map && data.containsKey("message")) {
          print("API Message: ${data["message"]}");
          setState(() {
            clearanceRequests = [];
            isLoading = false;
          });
        } else {
          setState(() {
            clearanceRequests = data;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load Clearance requests");
      }
    } catch (error) {
      print("Error fetching Clearance requests: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068),
      appBar: AppBar(
        title: const Text('Clearance Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : clearanceRequests.isEmpty
            ? const Center(child: Text("No Clearance requests found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: clearanceRequests.length,
          itemBuilder: (context, index) {
            return _buildClearanceEntry(clearanceRequests[index]);
          },
        ),
      ),
    );
  }

  Widget _buildClearanceEntry(dynamic request) {
    // Handle potential null values
    String firstName = request['firstName'] ?? 'Unknown';
    String lastName = request['lastName'] ?? 'Unknown';
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
                Text("Name: $firstName $lastName", style: const TextStyle(color: Colors.black)),
                Text("Date: $dateRequested", style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
