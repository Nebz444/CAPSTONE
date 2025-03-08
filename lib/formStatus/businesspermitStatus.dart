import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BusinessPermitStatusPage extends StatefulWidget {
  final int userId;

  BusinessPermitStatusPage({required this.userId});

  @override
  _BusinessPermitStatusPageState createState() => _BusinessPermitStatusPageState();
}

class _BusinessPermitStatusPageState extends State<BusinessPermitStatusPage> {
  List<dynamic> businessPermitRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusinessPermitRequests();
  }

  Future<void> fetchBusinessPermitRequests() async {
    final url = Uri.parse('https://manibaugparalaya.com/API/getBusinessPermit.php?user_id=${widget.userId}');

    try {
      print("Fetching Business Permit data for user_id: ${widget.userId}");
      final response = await http.get(url);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded API Response: ${json.encode(data)}");

        if (data is Map && data.containsKey("message")) {
          print("API Message: ${data["message"]}");
          setState(() {
            businessPermitRequests = [];
            isLoading = false;
          });
        } else {
          setState(() {
            businessPermitRequests = data;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load Business Permit requests");
      }
    } catch (error) {
      print("Error fetching Business Permit requests: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068),
      appBar: AppBar(
        title: const Text('Business Permit Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : businessPermitRequests.isEmpty
            ? const Center(child: Text("No Business Permit requests found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: businessPermitRequests.length,
          itemBuilder: (context, index) {
            return _buildBusinessPermitEntry(businessPermitRequests[index]);
          },
        ),
      ),
    );
  }

  Widget _buildBusinessPermitEntry(dynamic request) {
    // Handle potential null values
    String businessName = request['business_name'] ?? 'Unknown';
    String ownerName = request['owner_name'] ?? 'Unknown';
    String businessType = request['business_type'] ?? 'N/A';
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
                Text("Business: $businessName", style: const TextStyle(color: Colors.black)),
                Text("Owner: $ownerName", style: const TextStyle(color: Colors.black)),
                Text("Type: $businessType", style: const TextStyle(color: Colors.black)),
                Text("Date: $dateRequested", style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
