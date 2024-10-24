import 'package:flutter/material.dart';
import 'dart:async';

class BaranguardDashboard extends StatefulWidget {
  final String username; // Username to display or use

  BaranguardDashboard({required this.username}); // Constructor to receive username

  @override
  _BaranguardDashboardState createState() => _BaranguardDashboardState();
}

class _BaranguardDashboardState extends State<BaranguardDashboard> {
  bool _showWelcomeText = true; // Control the visibility of the welcome text

  @override
  void initState() {
    super.initState();

    // Set a timer to hide the welcome text after 3 seconds
    Timer(Duration(seconds: 3), () {
      setState(() {
        _showWelcomeText = false; // Hide the welcome text after 3 seconds
      });
    });
  }

  // Function to handle icon taps
  void _onIconTap(String iconName) {
    switch (iconName) {
      case 'home':
      // Navigate to Home
        print('Home icon tapped');
        break;
      case 'news':
      // Navigate to News
        print('Request icon tapped');
        break;
      case 'profile':
      // Navigate to Profile
        print('Complaints icon tapped');
        break;
      case 'report':
      // Navigate to Reports
        print('Reports icon tapped');
        break;
      case 'contacts':
      // Navigate to Contacts
        print('Contacts icon tapped');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baranguard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer using the correct context
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile_picture.png'), // Replace with your image asset
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red[200],
              ),
              child: Text(
                'Welcome, ${widget.username}', // Access username through widget
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer after selection
              },
            ),
            ListTile(
              leading: Icon(Icons.mail),
              title: Text('Request'),
              onTap: () {
                // Handle Settings tap
                Navigator.pop(context); // Close the drawer after selection
              },
            ),
            ListTile(
              leading: Icon(Icons.newspaper),
              title: Text('Complaints'),
              onTap: () {
                // Handle Logout tap
                Navigator.pop(context); // Close the drawer after selection
              },
            ),
            ListTile(
              leading: Icon(Icons.report_problem),
              title: Text('Reports'),
              onTap: () {
                // Handle Logout tap
                Navigator.pop(context); // Close the drawer after selection
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_emergency),
              title: Text('Contacts'),
              onTap: () {
                // Handle Logout tap
                Navigator.pop(context); // Close the drawer after selection
              },
            ),
            Divider(), // Optional: to add a divider between options
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'More Options', // Add "More Option" text
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle Logout tap
                Navigator.pop(context); // Close the drawer after selection
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.red[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _onIconTap('home'), // Handle Home icon tap
                  child: Container(
                    padding: EdgeInsets.all(12), // Add padding for better tap area
                    decoration: BoxDecoration(
                      color: Colors.redAccent, // Bright background color
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Icon(Icons.home, color: Colors.white, size: 25), // Increase icon size
                  ),
                ),
                GestureDetector(
                  onTap: () => _onIconTap('news'), // Handle News icon tap
                  child: Container(
                    padding: EdgeInsets.all(12), // Add padding for better tap area
                    decoration: BoxDecoration(
                      color: Colors.redAccent, // Bright background color
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Icon(Icons.newspaper, color: Colors.white, size: 25), // Increase icon size
                  ),
                ),
                GestureDetector(
                  onTap: () => _onIconTap('profile'), // Handle Profile icon tap
                  child: Container(
                    padding: EdgeInsets.all(12), // Add padding for better tap area
                    decoration: BoxDecoration(
                      color: Colors.redAccent, // Bright background color
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 25), // Increase icon size
                  ),
                ),
                GestureDetector(
                  onTap: () => _onIconTap('report'), // Handle Report icon tap
                  child: Container(
                    padding: EdgeInsets.all(12), // Add padding for better tap area
                    decoration: BoxDecoration(
                      color: Colors.redAccent, // Bright background color
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Icon(Icons.report_problem, color: Colors.white, size: 25), // Increase icon size
                  ),
                ),
                GestureDetector(
                  onTap: () => _onIconTap('contacts'), // Handle Contacts icon tap
                  child: Container(
                    padding: EdgeInsets.all(12), // Add padding for better tap area
                    decoration: BoxDecoration(
                      color: Colors.redAccent, // Bright background color
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Icon(Icons.phone_android_rounded, color: Colors.white, size: 25), // Increase icon size
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Visibility(
                visible: _showWelcomeText,
                child: Text(
                  'Welcome, ${widget.username}', // Display username on the dashboard
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
