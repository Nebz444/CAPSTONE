import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BarangayIDStatusPage extends StatefulWidget {
  final int userId;

  BarangayIDStatusPage({required this.userId});

  @override
  _BarangayIDStatusPageState createState() => _BarangayIDStatusPageState();
}

class _BarangayIDStatusPageState extends State<BarangayIDStatusPage> {
  List<dynamic> barangayIDRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBarangayIDRequests();
  }

  Future<void> fetchBarangayIDRequests() async {
    final url1 = Uri.parse('https://manibaugparalaya.com/API/getBarangayID.php?user_id=${widget.userId}');
    final url2 = Uri.parse('https://manibaugparalaya.com/API/getBarangayID1.php?user_id=${widget.userId}');

    try {
      print("Fetching Barangay ID data for user_id: ${widget.userId}");

      // Fetch both APIs in parallel
      final response1 = await http.get(url1);
      final response2 = await http.get(url2);

      print("Response1 Status: ${response1.statusCode}");
      print("Response2 Status: ${response2.statusCode}");

      List barangayIDRequests = [];

      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        print("Response1 Data: ${json.encode(data1)}");
        if (data1 is List) barangayIDRequests.addAll(data1);
      }

      if (response2.statusCode == 200) {
        final data2 = json.decode(response2.body);
        print("Response2 Data: ${json.encode(data2)}");
        if (data2 is List) barangayIDRequests.addAll(data2);
      }

      setState(() {
        this.barangayIDRequests = barangayIDRequests;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching Barangay ID requests: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068),
      appBar: AppBar(
        title: const Text('Barangay ID Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : barangayIDRequests.isEmpty
            ? const Center(child: Text("No Barangay ID requests found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: barangayIDRequests.length,
          itemBuilder: (context, index) {
            return _buildBarangayIDEntry(barangayIDRequests[index]);
          },
        ),
      ),
    );
  }

  Widget _buildBarangayIDEntry(dynamic request) {
    // Handle potential null values
    String firstName = request['first_name'] ?? 'Unknown';
    String lastName = request['last_name'] ?? 'Unknown';
    String status = request['status'] ?? 'pending';
    String dateRequested = request['created_at'] ?? 'N/A';

    // Define status color based on status value
    Color statusColor = status == 'accepted' ? Colors.green : (status == 'pending' ? Colors.orange : Colors.orange);

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
