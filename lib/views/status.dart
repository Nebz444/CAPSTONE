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
      backgroundColor: const Color(0xFF154068), // Dark blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.02, // 5% of screen width
                vertical: constraints.maxHeight * 0.02, // 5% of screen height
              ),
              child: Column(
                children: [
                  _buildHeader(constraints),
                  const SizedBox(height: 30),
                  _buildReportStatusButton(context),
                  const SizedBox(height: 20),
                  _buildComplaintsStatusButton(context),
                  const SizedBox(height: 20),
                  _buildBarangayIDStatusButton(context),
                  const SizedBox(height: 20),
                  _buildCedulaStatusButton(context),
                  const SizedBox(height: 20),
                  _buildCertificateStatusButton(context),
                  const SizedBox(height: 20),
                  _buildIndigencyStatusButton(context),
                  const SizedBox(height: 20),
                  _buildBusinessPermitStatusButton(context),
                  const SizedBox(height: 20),
                  _buildClearanceStatusButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

//Report
  Widget _buildReportStatusButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('user_id'); // Retrieve userId

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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            "Report Status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

//Complaints
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

//Certificates
Widget _buildCertificateStatusButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id'); // Retrieve userId

      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CertificateStatusPage(userId: userId), // Pass userId
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
          "Certificate Status",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

Widget _buildBarangayIDStatusButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id'); // Retrieve userId

      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarangayIDStatusPage(userId: userId), // Pass userId
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
          "Barangay ID Status",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

//cedula
Widget _buildCedulaStatusButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id'); // Retrieve userId

      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CedulaStatusPage(userId: userId), // Pass userId
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
          "Cedula Status",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

//indigency
Widget _buildIndigencyStatusButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id'); // Retrieve userId

      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndigencyStatusPage(userId: userId), // Pass userId
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
          "Indigency Status",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

//Business Permit
Widget _buildBusinessPermitStatusButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id'); // Retrieve userId

      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessPermitStatusPage(userId: userId), // Pass userId
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
          "Business Permit Status",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

//Business Permit
Widget _buildClearanceStatusButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id'); // Retrieve userId

      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClearanceStatusPage(userId: userId), // Pass userId
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
          "Clearance Status",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}


Widget _buildHeader(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          "Status",
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String text, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.9, // 90% of screen width
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
    );
  }
