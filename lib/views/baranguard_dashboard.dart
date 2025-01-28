import 'dart:io';

import 'package:flutter/material.dart';
import 'package:baranguard/views/account_settings_page.dart';
import 'package:baranguard/views/complaints.dart';
import 'package:baranguard/views/request_page.dart';
import 'package:baranguard/Login.dart';
import 'package:baranguard/views/contact.dart';
import 'package:baranguard/views/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaranguardDashboard extends StatefulWidget {
  final String username;

  BaranguardDashboard({required this.username});

  @override
  _BaranguardDashboardState createState() => _BaranguardDashboardState();
}

class _BaranguardDashboardState extends State<BaranguardDashboard> {
  int _currentIndex = 2; // Default index for the home tab
  File? _profileImage;

  final List<Widget> _pages = [
    RequestPage(),
    ComplaintsForm(),
    Center(child: Text("Home")), // Placeholder for home
    ReportPage(),
    ContactPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Load the profile image
  }

  // Load profile image from SharedPreferences
  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImage');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // Navigate to Account Settings Page
  void _navigateToAccountSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountSettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baranguard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _navigateToAccountSettings,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/default_profile.png'),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red[200]),
              child: Text(
                'Welcome, ${widget.username}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Request'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RequestPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Complaints'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintsForm()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Contacts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactPage()),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'More Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BaranguardLoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex], // Display selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update current index on tap
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: "Request",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Complaints",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: "Report",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: "Contacts",
          ),
        ],
      ),
    );
  }
}
