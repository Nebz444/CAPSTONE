import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/users_model.dart';
import '../provider/user_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    requestPermissions(); // Ensure permissions are granted
    fetchUserDetails();
  }

  Future<void> requestPermissions() async {
    await Permission.photos.request();
    await Permission.camera.request();
  }

  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;

    if (user?.birthday != null) {
      birthday = DateFormat('yyyy-MM-dd').format(user!.birthday!);
    } else {
      birthday = "No Birthday Provided";
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedProfileImage = prefs.getString('profileImage');

    if (savedProfileImage != null && savedProfileImage.isNotEmpty) {
      setState(() {
        user!.profileImage = savedProfileImage;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("Image picked: ${pickedFile.path}"); // Debugging
      File imageFile = File(pickedFile.path);
      checkFileType(imageFile);
      String? uploadedImageUrl = await _uploadProfileImage(imageFile);

      if (uploadedImageUrl != null) {
        setState(() {
          _profileImage = imageFile;
          user!.profileImage = uploadedImageUrl;
        });

        // Update the UserProvider with the new profile image
        Provider.of<UserProvider>(context, listen: false).updateProfileImage(uploadedImageUrl);

        // Save the new profile image URL to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImage', uploadedImageUrl);

        print("Profile image updated and saved to SharedPreferences: $uploadedImageUrl");
      } else {
        print("Failed to upload profile image."); // Debugging
      }
    } else {
      print("No image selected."); // Debugging
    }
  }

  void checkFileType(File imageFile) {
    final mimeType = lookupMimeType(imageFile.path);
    print("Detected MIME type: $mimeType");
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      // Print debug information
      print("Image picked: ${imageFile.path}");
      print("Sending request with user_id: ${user!.id} and action: upload_profile_picture");

      // Create the multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://baranguard.shop/API/dartdb.php'), // Correct API URL
      );

      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Ensure this matches the server's expected field name
        imageFile.path,
      ));

      // Add additional fields
      request.fields['user_id'] = user!.id.toString();
      request.fields['action'] = 'upload_profile_picture'; // Ensure this matches the server's expected action

      // Print the request fields for debugging
      print("Request fields: ${request.fields}");

      // Send the request
      var response = await request.send();

      // Get the response data
      var responseData = await response.stream.bytesToString();
      print("Upload Response: $responseData"); // Debugging

      // Parse the JSON response
      var jsonResponse = json.decode(responseData);

      // Check if the upload was successful
      if (jsonResponse['status'] == 'success') {
        print("Uploaded Image URL: ${jsonResponse['profile_image_path']}"); // Log success
        return jsonResponse['profile_image_path'];
      } else {
        print("Error: ${jsonResponse['message']}"); // Log error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: ${jsonResponse['message']}")),
        );
      }
    } catch (e) {
      print("Exception: $e"); // Log any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
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
          Center(
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) as ImageProvider
                    : user?.profileImage != null
                    ? NetworkImage(user!.profileImage!)
                    : const AssetImage('lib/images/default_profile.png'),
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
          _buildInfoRow("Last Name", user?.lastName),
          _buildInfoRow("First Name", user?.firstName),
          _buildInfoRow("Middle Name", user?.middleName),
          _buildInfoRow("Suffix", user?.suffix),
          _buildInfoRow("Birthday", birthday),
          _buildInfoRow("Username", user?.username),
          _buildInfoRow("Mobile Number", user?.mobileNumber),
          _buildInfoRow("Email Address", user?.email),
          _buildInfoRow("Home Address", user?.homeAddress),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            flex: 3,
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}