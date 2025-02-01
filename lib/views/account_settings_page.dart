import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  }

  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;

    if (user?.birthday != null) {
      birthday = DateFormat('yyyy-MM-dd').format(user!.birthday!);
    } else {
      birthday = "No Birthday Provided";
    }

    // Load profile image from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedProfileImage = prefs.getString('profileImage');

    if (savedProfileImage != null && savedProfileImage.isNotEmpty) {
      setState(() {
        user!.profileImage = savedProfileImage;
      });
    }
  }

  // Pick a new profile picture and upload to the API
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String? uploadedImageUrl = await _uploadProfileImage(imageFile);

      if (uploadedImageUrl != null) {
        setState(() {
          _profileImage = imageFile;
        });

        // Update UserProvider with new profile image URL
        Provider.of<UserProvider>(context, listen: false).updateProfileImage(uploadedImageUrl);
      }
    }
  }

  // Upload profile image to API
  Future<String?> _uploadProfileImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.100.149/dartdb/dartdb.php'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['user_id'] = user!.id.toString();
    request.fields['action'] = 'upload_profile_picture'; // Required by the API

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (jsonResponse['status'] == 'success') {
        return jsonResponse['profile_image_path']; // Return the correct image path
      }
    }

    return null;
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
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) as ImageProvider
                    : user?.profileImage != null
                    ? NetworkImage(user!.profileImage!)
                    : const AssetImage('assets/default_profile.png'),
                child: _profileImage == null && user?.profileImage == null
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
