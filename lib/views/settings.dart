import 'package:baranguard/views/aboutUs.dart';
import 'package:baranguard/views/helpSupport.dart';
import 'package:flutter/material.dart';
import 'package:baranguard/views/account_settings_page.dart';
import 'package:baranguard/views/change_password_page.dart'; // Import the new ChangePasswordPage
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart'; // Add this import for file storage
import 'dart:io'; // For file operations
import 'package:open_file/open_file.dart';
import 'aboutUs.dart';


import 'package:url_launcher/url_launcher.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> fetchUpdate(BuildContext context) async {
    final apiUrl = 'https://manibaugparalaya.com/API/fetch_updater.php';
    final dio = Dio();

    try {
      // Fetch file URL from API
      final response = await dio.get(apiUrl);

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch update: ${response.statusCode}");
      }

      final data = response.data is String ? jsonDecode(response.data) : response.data;

      if (data == null || !data.containsKey('link')) {
        throw Exception("No valid file URL found in response");
      }

      final fileUrl = data['link']; // Google Drive or direct download link

      // Open the link in browser
      if (await canLaunchUrl(Uri.parse(fileUrl))) {
        await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Could not open the link");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154C79),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildSectionHeader('Account'),
            _buildListTile(
              title: 'Account Settings',
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountSettingsPage()),
                );
              },
            ),
            _buildListTile(
              title: 'Change Password',
              icon: Icons.lock,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Support'),
            _buildListTile(
              title: 'Help & Support',
              icon: Icons.help,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpSupportPage()),
                );
              },
            ),
            _buildListTile( // put it here the update button
              title: 'Check for Updates',
              icon: Icons.system_update,
              onTap: () => fetchUpdate(context),
            ),
            _buildListTile(
              title: 'About Us',
              icon: Icons.info,
              onTap: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => AboutUsPage()),
                 );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF154C79)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
