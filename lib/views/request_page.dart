import 'package:flutter/material.dart';
import 'package:baranguard/forms/barangay_id.dart'; // Import the Barangay ID form page
import 'package:baranguard/forms/cedula.dart';
import '../forms/barangay_certificate.dart';
import '../forms/indigency.dart';
import '../forms/business_permit.dart';
import '../forms/clearance.dart';

class RequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    double imageOpacity = 0.3; // Set the desired opacity value

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56), // Dark blue matching the design
        title: const Text('Request', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
          children: [
            // Background Image with Opacity
            Positioned(
              left: .9, // Adjust horizontal position (distance from the left)
              top: 180, // Adjust vertical position (distance from the top)
              child: Opacity(
                opacity: imageOpacity, // Adjust opacity here (0.0 to 1.0)
                child: Container(
                  width: 400,
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/images/reqBG.png'), // Path to your image
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
                  buildRequestButton(context, 'Barangay ID', BarangayID(formType: 'Barangay ID')),
                  const SizedBox(height: 10),
                  buildRequestButton(context, 'Cedula', Cedula(formType: 'Cedula')),
                  const SizedBox(height: 10),
                  buildRequestButton(context, 'Barangay Certificate', BarangayCertificateForm(formType: 'Barangay Certificate')),
                  const SizedBox(height: 10),
                  buildRequestButton(context, 'Certificate of Indigency', IndigencyForm(formType: 'Indigency Form')),
                  const SizedBox(height: 10),
                  buildRequestButton(context, 'Business Permit', BusinessForm(formType: 'Business Permit')),
                  const SizedBox(height: 10),
                  buildRequestButton(context, 'Clearance', Clearance(formType: 'Clearance'))
                ],
              ),
            ),
          ]
      ),
    );
  }

  // Helper function to create request buttons
  Widget buildRequestButton(BuildContext context, String title, Widget? formPage) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF174A7C), // Lighter blue matching the design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: () {
        if (formPage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => formPage),
          );
        } else {
          // Handle other requests if needed
          print('$title clicked');
        }
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, color: Colors.white), // White text for better contrast
      ),
    );
  }
}