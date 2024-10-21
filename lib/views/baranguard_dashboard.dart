import 'package:flutter/material.dart';

class BaranguardDashboard extends StatelessWidget {
  final String username;  // Username to display or use

  BaranguardDashboard({required this.username});  // Constructor to receive username

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baranguard'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Add menu action here
          },
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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.red[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.description, color: Colors.white),
                Icon(Icons.person, color: Colors.white),
                Icon(Icons.vpn_key, color: Colors.white),
                Icon(Icons.notification_important, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Welcome, $username',  // Display username on the dashboard
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
