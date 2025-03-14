import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'report.dart'; // Import the ReportPage class
import 'reportstatus.dart'; // Import the ReportStatusPage class

class ReportFirstPage extends StatelessWidget {
  const ReportFirstPage({super.key});

  @override
  Widget build(BuildContext context) {

    double imageOpacity = 0.3; // Set the desired opacity value

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56), // Dark blue matching the design
        title: const Text('Report', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Image with Opacity
          Positioned(
            left: .3, // Adjust horizontal position (distance from the left)
            top: 180, // Adjust vertical position (distance from the top)
            child: Opacity(
              opacity: imageOpacity, // Adjust opacity here (0.0 to 1.0)
              child: Container(
                width: 400,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/images/repBG.png'), // Path to your image
                    fit: BoxFit.cover, // Cover the entire screen
                  ),
                ),
              ),
            ),
          ),
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildReportButton(context, 'Submit a Report', ReportPage()),
                const SizedBox(height: 10),
                _buildReportStatusButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade900, // Button background color
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildReportStatusButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('user_id'); // R etrieve userId

        if (userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportStatusPage(userId: userId), // Pass userId
            ),
          );
        } else {
          // Handle case where userId is missing
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID not found. Please log in again.")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade900, // Button background color
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
      child: const Text(
        'Report Status',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}