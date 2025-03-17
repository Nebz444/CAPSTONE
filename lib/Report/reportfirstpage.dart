import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'report.dart';
import 'reportstatus.dart';

class ReportFirstPage extends StatelessWidget {
  const ReportFirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildReportOption(context, Icons.report, 'Submit a Report', const ReportPage()),
            _buildReportStatusOption(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(BuildContext context, IconData icon, String title, Widget page) {
    return _buildListTile(
      context,
      icon,
      title,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildReportStatusOption(BuildContext context) {
    return _buildListTile(
      context,
      Icons.assignment_turned_in,
      'Report Status',
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('user_id');

        if (userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportStatusPage(userId: userId)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID not found. Please log in again.")),
          );
        }
      },
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2),),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade900),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap ?? () {},
      ),
    );
  }
}