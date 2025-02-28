import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baranguard/provider/user_provider.dart';
import 'package:baranguard/views/account_settings_page.dart';
import 'package:baranguard/views/complaints.dart';
import 'package:baranguard/views/request_page.dart';
import 'package:baranguard/views/contact.dart';
import 'package:baranguard/views/report.dart';
import 'package:baranguard/firstPage.dart';
import 'package:baranguard/views/settings.dart';
import 'package:baranguard/utils/route_utils.dart';
import 'package:baranguard/views/baranguardfeed.dart';

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

  final List<Widget> _pages = [
    RequestPage(),
    ComplaintsForm(),
    const BaranguardFeed(), // BaranguardFeed is one of the pages
    ReportPage(),
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
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  userProvider.clearUser();

                  SharedPreferences prefs = await SharedPreferences.getInstance();
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
        backgroundColor: const Color(0xFF154C79),
        title: const Text(
          'Baranguard',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          // Notification Icon (without badge or functionality)
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Add notification functionality here if needed
            },
          ),
          // Profile Icon
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, RouteUtils.createRoute(AccountSettingsPage()));
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: userProvider.user?.profileImage != null &&
                        userProvider.user!.profileImage!.isNotEmpty
                        ? NetworkImage(userProvider.user!.profileImage!)
                        : const AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF154C79)),
              child: Text(
                'Welcome, ${userProvider.user?.username ?? "User"}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Request'),
              onTap: () {
                Navigator.push(context, RouteUtils.createRoute(RequestPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Complaints'),
              onTap: () {
                Navigator.push(context, RouteUtils.createRoute(ComplaintsForm()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Reports'),
              onTap: () {
                Navigator.push(context, RouteUtils.createRoute(ReportPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Contacts'),
              onTap: () {
                Navigator.push(context, RouteUtils.createRoute(const ContactPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(context, RouteUtils.createRoute(SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF154C79),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article, size: 30), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.people, size: 30), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 35), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign, size: 30), label: 'Announcements'),
          BottomNavigationBarItem(icon: Icon(Icons.phone, size: 30), label: 'Contact'),
        ],
      ),
    );
  }
}