import 'package:flutter/material.dart';
import 'package:baranguard/forms/barangay_id.dart'; // Import the Barangay ID form page
import 'package:baranguard/forms/cedula.dart';
import '../forms/barangay_certificate.dart';
import '../forms/indigencey.dart';
import '../forms/business_permit.dart';

class RequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56), // Dark blue matching the design
        title: const Text('Request', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildRequestButton(context, 'Barangay ID', BarangayID(formType: 'Barangay ID')),
            const SizedBox(height: 10),
            buildRequestButton(context, 'Cedula', CedulaForm(formType: 'Cedula')),
            const SizedBox(height: 10),
            buildRequestButton(context, 'Barangay Certificate', BarangayCertificateForm(formType: 'Barangay Certificate')),
            const SizedBox(height: 10),
            buildRequestButton(context, 'Certificate of Indigency', IndigencyForm(formType: 'Indigency Form')),
            const SizedBox(height: 10),
            buildRequestButton(context, 'Business Permit', BusinessForm(formType: 'Business Permit'))
          ],
        ),
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