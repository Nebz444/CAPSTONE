import 'package:flutter/material.dart';
import 'package:baranguard/forms/barangay_id.dart';
import 'package:baranguard/forms/cedula.dart';
import '../forms/barangay_certificate.dart';
import '../forms/indigency.dart';
import '../forms/business_permit.dart';
import '../forms/clearance.dart';

class RequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFF),
        elevation: 0,
        title: const Text(
          'Request',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false, // Aligns title to the left
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            buildRequestTile(context, Icons.credit_card, "Barangay ID", BarangayID(formType: 'Barangay ID')),
            buildRequestTile(context, Icons.receipt, "Cedula", Cedula(formType: 'Cedula')),
            buildRequestTile(context, Icons.verified_user, "Barangay Certificate", BarangayCertificateForm(formType: 'Barangay Certificate')),
            buildRequestTile(context, Icons.account_balance, "Certificate of Indigency", IndigencyForm(formType: 'Indigency Form')),
            buildRequestTile(context, Icons.business, "Business Clearance", BusinessForm(formType: 'Business Permit')),
            buildRequestTile(context, Icons.assignment_turned_in, "Barangay Clearance", Clearance(formType: 'Clearance')),
          ],
        ),
      ),
    );
  }

  Widget buildRequestTile(BuildContext context, IconData icon, String title, Widget? formPage) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
        onTap: () {
          if (formPage != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => formPage),
            );
          }
        },
      ),
    );
  }
}