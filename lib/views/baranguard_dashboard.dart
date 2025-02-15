import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart'; // Import webview_flutter
import 'package:baranguard/provider/user_provider.dart';
import 'package:baranguard/views/account_settings_page.dart';
import 'package:baranguard/views/complaints.dart';
import 'package:baranguard/views/request_page.dart';
import 'package:baranguard/Login.dart';
import 'package:baranguard/views/contact.dart';
import 'package:baranguard/views/report.dart';
import '../model/users_model.dart';

class BaranguardDashboard extends StatefulWidget {
  @override
  _BaranguardDashboardState createState() => _BaranguardDashboardState();
}

class _BaranguardDashboardState extends State<BaranguardDashboard> {
  int _currentIndex = 2; // Default index for the home tab
  User? user;

  final List<Widget> _pages = [
    RequestPage(),
    ComplaintsForm(),
    FacebookMediaFeed(), // Updated Home Page with Facebook Feed
    ReportPage(),
    ContactPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Load user profile
  Future<void> _fetchUserProfile() async {
    user = Provider.of<UserProvider>(context, listen: false).user;
  }

  // Navigate to Account Settings Page
  void _navigateToAccountSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountSettingsPage()),
    );
  }

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
                Provider.of<UserProvider>(context, listen: false).clearUser();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BaranguardLoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundImage: userProvider.user?.profileImage != null &&
                        userProvider.user!.profileImage!.isNotEmpty
                        ? NetworkImage(userProvider.user!.profileImage!)
                        : const AssetImage('assets/default_profile.png') as ImageProvider,
                  );
                },
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
                'Welcome, ${user?.username ?? "User"}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Request'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => RequestPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Complaints'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintsForm()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Contacts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex], // Display selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Request"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Complaints"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: "Contacts"),
        ],
      ),
    );
  }
}

// Facebook Media Feed Page using WebView
class FacebookMediaFeed extends StatefulWidget {
  @override
  _FacebookMediaFeedState createState() => _FacebookMediaFeedState();
}

class _FacebookMediaFeedState extends State<FacebookMediaFeed> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
              "(KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            // If it's a Facebook link, try opening in the Facebook app
            if (request.url.contains("facebook.com")) {
              Uri fbAppUri = Uri.parse("fb://facewebmodal/f?href=${request.url}");
              if (await canLaunchUrl(fbAppUri)) {
                await launchUrl(fbAppUri); // Open in Facebook app
              } else {
                await launchUrl(Uri.parse(request.url)); // Open in browser
              }
              return NavigationDecision.prevent; // Stop WebView from loading
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_generateFacebookEmbed());
  }

  String _generateFacebookEmbed() {
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
      <meta charset="UTF-8">
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          background: #f8f9fa;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          overflow: hidden;
        }
        .fb-container {
          width: 100vw;
          max-width: 100%;
          height: 100vh;
          overflow: hidden;
          position: relative;
        }
        iframe {
          width: 100%;
          height: 100%;
          border: none;
        }
      </style>
    </head>
    <body>
      <div class="fb-container">
        <iframe
          id="fb-frame"
          src="https://www.facebook.com/plugins/page.php?href=https://www.facebook.com/PhilippineSTAR&tabs=timeline&width=500&height=800&small_header=true&adapt_container_width=true&hide_cover=false&show_facepile=true"
          scrolling="no">
        </iframe>
      </div>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}