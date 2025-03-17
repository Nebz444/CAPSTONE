import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baranguard/provider/user_provider.dart';
import 'package:baranguard/views/account_settings_page.dart';
import 'package:baranguard/Complaints/complaints.dart';
import 'package:baranguard/views/request_page.dart';
import 'package:baranguard/views/contact.dart';
import 'package:baranguard/Report/report.dart';
import 'package:baranguard/firstPage.dart';
import 'package:baranguard/views/settings.dart';
import 'package:baranguard/utils/route_utils.dart';
import 'package:baranguard/views/baranguardfeed.dart';
import '../Report/reportfirstpage.dart';
import 'package:baranguard/Complaints/complaintsfirstpage.dart';
import 'status.dart';

class BaranguardDashboard extends StatefulWidget {
  const BaranguardDashboard({super.key});

  @override
  _BaranguardDashboardState createState() => _BaranguardDashboardState();
}

class _BaranguardDashboardState extends State<BaranguardDashboard> {
  int _selectedIndex = 2; // Default selected index (Home)
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  // Main buttons
  final List<Widget> _pages = [
    RequestPage(),
    ComplaintsFirstpage(),
    const BaranguardFeed(), // BaranguardFeed is one of the pages
    ReportFirstPage(),
    const ContactPage(),
  ];

  // Confirm Logout Dialog
  Future<void> _confirmLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final userProvider = Provider.of<UserProvider>(
                      context, listen: false);
                  userProvider.clearUser();

                  SharedPreferences prefs = await SharedPreferences
                      .getInstance();
                  await prefs.remove('profileImage');
                  await prefs.remove('username');

                  Navigator.pushAndRemoveUntil(
                    context,
                    RouteUtils.createRoute(const BaranguardWelcomePage()),
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print("Error during logout: $e");
                }
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56),
        title: const Text(
          'baranguard',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context, RouteUtils.createRoute(AccountSettingsPage()));
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: userProvider.user?.profileImage != null &&
                        userProvider.user!.profileImage!.isNotEmpty
                        ? NetworkImage(userProvider.user!.profileImage!)
                        : const AssetImage(
                        'lib/images/default_profile.png') as ImageProvider,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Color(0xFF154C79), // Dark blue background
                        ),
                        padding: EdgeInsets.zero, // Remove default padding
                        margin: EdgeInsets.zero, // Remove default margin
                        child: Stack(
                          children: [
                            // Transparent image as background
                            Opacity(
                              opacity: 0.3, // Adjust opacity for transparency
                              child: Image.asset(
                                'lib/images/Logo.png', // Path to your transparent image
                                fit: BoxFit.cover, // Cover the entire DrawerHeader
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            // Center the profile picture and welcome text
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                                children: [
                                  CircleAvatar(
                                    radius: 42, // Reduced size
                                    backgroundColor: Colors.white, // Yellow border color
                                    child: CircleAvatar(
                                      radius: 40, // Slightly smaller radius to create a border effect
                                      backgroundColor: Colors.white, // Inner circle background color
                                      backgroundImage: userProvider.user?.profileImage != null &&
                                          userProvider.user!.profileImage!.isNotEmpty
                                          ? NetworkImage(userProvider.user!.profileImage!)
                                          : const AssetImage('lib/images/default_profile.png'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Welcome, ${userProvider.user?.username ?? "User"}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22, // Reduced font size
                                      fontWeight: FontWeight.bold, // Make the text bold
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.mail),
                    title: const Text('Request'),
                    onTap: () {
                      Navigator.push(
                          context, RouteUtils.createRoute(RequestPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.campaign),
                    title: const Text('Complaints'),
                    onTap: () {
                      Navigator.push(
                          context, RouteUtils.createRoute(ComplaintsForm()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.report_problem),
                    title: const Text('Reports'),
                    onTap: () {
                      Navigator.push(
                          context, RouteUtils.createRoute(ReportPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Contacts'),
                    onTap: () {
                      Navigator.push(
                          context, RouteUtils.createRoute(const ContactPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article),
                    title: const Text('Status'),
                    onTap: () {
                      Navigator.push(
                          context, RouteUtils.createRoute(const StatusPage()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.push(
                          context, RouteUtils.createRoute(SettingsPage()));
                    },
                  ),
                ],
              ),
            ),
            // Logout Button with Rounded Corners
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity, // Make the button take full width
                decoration: BoxDecoration(
                  color: const Color(0xFF154C79), // Dark blue background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () => _confirmLogout(context),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white, // White text
                      fontSize: 16, // Font size
                      fontWeight: FontWeight.bold, // Bold text
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF154C79),
        selectedItemColor: Colors.yellow[200],
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 0
                    ? Colors.white.withOpacity(0.4)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.mail, size: 24),
            ),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 1
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.campaign, size: 24),
            ),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 2
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.home, size: 28),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 3
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.report_problem, size: 24),
            ),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 4
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: const Icon(Icons.phone, size: 24),
            ),
            label: 'Hotlines',
          ),
        ],
      ),
    );
  }
}
