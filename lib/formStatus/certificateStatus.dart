import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CertificateStatusPage extends StatefulWidget {
  final int userId;

  CertificateStatusPage({required this.userId});

  @override
  _CertificateStatusPageState createState() => _CertificateStatusPageState();
}

class _CertificateStatusPageState extends State<CertificateStatusPage> {
  List<dynamic> certificateRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCertificateRequests();
  }

  Future<void> fetchCertificateRequests() async {
    final url = Uri.parse('https://manibaugparalaya.com/API/getCertificate.php?user_id=${widget.userId}');

    try {
      print("Fetching data for user_id: ${widget.userId}");
      final response = await http.get(url);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded API Response: ${json.encode(data)}"); // Debugging Line

        if (data is Map && data.containsKey("message")) {
          print("API Message: ${data["message"]}");
          setState(() {
            certificateRequests = [];
            isLoading = false;
          });
        } else {
          setState(() {
            certificateRequests = data;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load certificate requests");
      }
    } catch (error) {
      print("Error fetching certificate requests: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068), // Background color
      appBar: AppBar(
        title: const Text('Certificate Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : certificateRequests.isEmpty
            ? const Center(child: Text("No certificate requests found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: certificateRequests.length,
          itemBuilder: (context, index) {
            return _buildCertificateEntry(certificateRequests[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCertificateEntry(dynamic request) {
    // Handle potential null values
    String firstName = request['first_name'] ?? 'Unknown';
    String lastName = request['last_name'] ?? 'Unknown';
    String userType = request['usertype'] ?? 'Not Available'; // Fix for usertype null issue
    String status = request['status'] ?? 'Pending';
    String dateRequested = request['created_at'] ?? 'N/A';

    // Define status color based on status value
    Color statusColor = status == 'Accepted' ? Colors.green : (status == 'Pending' ? Colors.orange : Colors.orange);

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
                Text("User Type: $userType", style: const TextStyle(color: Colors.black)),
                Text("Date: $dateRequested", style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
