import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'complaintsstatus.dart'; // Import the ReportPage class
import 'complaints.dart';

class ComplaintsFirstpage extends StatelessWidget {
  const ComplaintsFirstpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068), // Dark blue background
      appBar: AppBar(
        title: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Complaints",
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildComplaintsButton("Complaints", context, ComplaintsForm()), // Navigate to ReportPage
            const SizedBox(height: 20),
            _buildComplaintsStatusButton(context), // Fetch userId before navigating
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsButton(String text, BuildContext context, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsStatusButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('user_id'); // Retrieve userId

        if (userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComplaintsStatusPage(userId: userId), // Pass userId
            ),
          );
        } else {
          // Handle case where userId is missing
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID not found. Please log in again.")),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            "Complaints Status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
