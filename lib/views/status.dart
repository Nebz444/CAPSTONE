import 'package:flutter/material.dart';
import 'package:baranguard/Report/reportstatus.dart';
import 'package:baranguard/Complaints/complaintsstatus.dart';
import 'package:baranguard/formStatus/certificateStatus.dart';
import 'package:baranguard/formStatus/barangayidStatus.dart';
import 'package:baranguard/formStatus/cedulaStatus.dart';
import 'package:baranguard/formStatus/indigencyStatus.dart';
import 'package:baranguard/formStatus/businesspermitStatus.dart';
import 'package:baranguard/formStatus/clearanceStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154C79),
        title: const Text(
          'Status',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D2D56), // Dark blue (top)
              Color(0xFF1E5A8A), // Medium blue (middle)
              Color(0xFF2D7BA7), // Lighter blue (bottom)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCategory('Reports', [
                      _buildStatusTile(
                          context, 'Report Status', Icons.report, (userId) =>
                          ReportStatusPage(userId: userId)),
                      _buildStatusTile(
                          context, 'Complaints Status', Icons.warning, (userId) =>
                          ComplaintsStatusPage(userId: userId)),
                    ]),
                    const SizedBox(height: 20),
                    _buildCategory('Documents', [
                      _buildStatusTile(
                          context, 'Barangay ID Status', Icons.badge, (userId) =>
                          BarangayIDStatusPage(userId: userId)),
                      _buildStatusTile(
                          context, 'Cedula Status', Icons.document_scanner, (userId) =>
                          CedulaStatusPage(userId: userId)),
                      _buildStatusTile(
                          context, 'Certificate Status', Icons.assignment, (userId) =>
                          CertificateStatusPage(userId: userId)),
                      _buildStatusTile(
                          context, 'Indigency Status', Icons.receipt, (userId) =>
                          IndigencyStatusPage(userId: userId)),
                      _buildStatusTile(
                          context, 'Business Permit Status', Icons.business, (userId) =>
                          BusinessPermitStatusPage(userId: userId)),
                      _buildStatusTile(
                          context, 'Clearance Status', Icons.check_circle, (userId) =>
                          ClearanceStatusPage(userId: userId)),
                    ]),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildStatusTile(BuildContext context, String title, IconData icon,
      Widget Function(int) pageBuilder) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('user_id');

        if (userId != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  pageBuilder(userId),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("User ID not found. Please log in again.")),
          );
        }
      },
    );
  }
}