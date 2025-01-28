import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To persist the profile picture path
import '../model/users_model.dart';
import '../provider/user_provider.dart';

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  User? user;
  String? birthday;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    _loadProfileImage(); // Load saved profile picture
  }

  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;

    if (user?.birthday != null) {
      birthday = DateFormat('yyyy-MM-dd').format(user!.birthday!);
    } else {
      birthday = "No Birthday Provided";
    }
  }

  // Load the saved profile image from SharedPreferences
  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImage');
    if (imagePath != null && mounted) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // Save the profile image path to SharedPreferences
  Future<void> _saveProfileImage(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', image.path);
  }

  // Pick a new profile picture
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _saveProfileImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Picture Section
          Center(
            child: GestureDetector(
              onTap: _pickProfileImage, // Pick a new profile picture
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) as ImageProvider
                    : const AssetImage('assets/default_profile.png'), // Use a default profile picture
                child: _profileImage == null
                    ? const Icon(
                  Icons.camera_alt,
                  size: 30,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow("Full Name", user?.fullName),
          _buildInfoRow("Birthday", birthday),
          _buildInfoRow("Username", user?.username),
          _buildInfoRow("Mobile Number", user?.mobileNumber),
          _buildInfoRow("Email Address", user?.email),
          _buildInfoRow("Home Address", user?.homeAddress),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon!')),
              );
            },
            child: const Text('Edit Account Details'),
          ),
        ],
      ),
    );
  }

  // Function to build info rows dynamically
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
