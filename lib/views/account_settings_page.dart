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
  bool _isEditing = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController suffixController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController homeAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermissions();
    fetchUserDetails();
  }

  Future<void> requestPermissions() async {
    await Permission.photos.request();
    await Permission.camera.request();
  }

  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      firstNameController.text = user!.firstName ?? '';
      lastNameController.text = user!.lastName ?? '';
      middleNameController.text = user!.middleName ?? '';
      suffixController.text = user!.suffix ?? '';
      mobileNumberController.text = user!.mobileNumber ?? '';
      emailController.text = user!.email ?? '';
      homeAddressController.text = user!.homeAddress ?? '';
    }

    if (user?.birthday != null) {
      birthday = DateFormat('yyyy-MM-dd').format(user!.birthday!);
    } else {
      birthday = "No Birthday Provided";
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedProfileImage = prefs.getString('profileImage');
    if (savedProfileImage != null) {
      setState(() {
        user!.profileImage = savedProfileImage;
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    try {
      final requestBody = {
        'action': 'update_profile',
        'username': user!.username,
        'last_name': lastNameController.text,
        'first_name': firstNameController.text,
        'middle_name': middleNameController.text,
        'suffix': suffixController.text,
        'email_address': emailController.text,
        'mobile_number': mobileNumberController.text,
        'home_address': homeAddressController.text,
      };

      final response = await http.post(
        Uri.parse('https://manibaugparalaya.com/API/dartdb.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        Provider.of<UserProvider>(context, listen: false).updateUser(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          middleName: middleNameController.text,
          suffix: suffixController.text,
          email: emailController.text,
          mobileNumber: mobileNumberController.text,
          homeAddress: homeAddressController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );

        setState(() {
          _isEditing = false;
        });

        await fetchUserDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${responseData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
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

        Provider.of<UserProvider>(context, listen: false).updateProfileImage(uploadedImageUrl);

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
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://manibaugparalaya.com/API/dartdb.php'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      request.fields['user_id'] = user!.id.toString();
      request.fields['action'] = 'upload_profile_picture'; // Ensure this matches the server's expected action

      // Print the request fields for debugging
      print("Request fields: ${request.fields}");
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      print("Upload Response: $responseData"); // Debugging

      // Parse the JSON response
      var jsonResponse = json.decode(responseData);

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
      backgroundColor: const Color(0xFF0D2D56), // Fallback color
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56), // Dark blue matching the design
        title: const Text('Account Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isEditing
              ? IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveChanges,
          )
              : IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, // Gradient starts at the top
                end: Alignment.bottomCenter, // Gradient ends at the bottom
                colors: [
                  Color(0xFF0D2D56), // Dark blue (top)
                  Color(0xFF1E5A8A), // Medium blue (middle)
                  Color(0xFF2D7BA7), // Lighter blue (bottom)
                ],
                stops: [0.0, 0.5, 1.0], // Control the transition points
              ),
            ),
          ),
          // Content
          if (user == null)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      width: 120, // Adjust size as needed
                      height: 120, // Adjust size as needed
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, // border color
                          width: 4.0, // Border thickness
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50, // Adjust size as needed
                        backgroundColor: Colors.white, // Inner circle background color
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!) as ImageProvider
                            : user?.profileImage != null
                            ? NetworkImage(user!.profileImage!)
                            : const AssetImage('lib/images/default_profile.png'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isEditing
                    ? _buildEditableStringField("First Name", firstNameController)
                    : _buildInfoRow("First Name", user?.firstName),
                _isEditing
                    ? _buildEditableStringField("Last Name", lastNameController)
                    : _buildInfoRow("Last Name", user?.lastName),
                _isEditing
                    ? _buildEditableStringField("Middle Name", middleNameController)
                    : _buildInfoRow("Middle Name", user?.middleName),
                _isEditing
                    ? _buildEditableStringField("Suffix", suffixController)
                    : _buildInfoRow("Suffix", user?.suffix),
                _buildInfoRow("Birthdate", birthday),
                _buildInfoRow("Username", user?.username),
                _buildInfoRow("Gender", user?.gender),
                _isEditing
                    ? _buildEditableStringField("Mobile Number", mobileNumberController)
                    : _buildInfoRow("Mobile Number", user?.mobileNumber),
                _isEditing
                    ? _buildEditableStringField("Email", emailController)
                    : _buildInfoRow("Email", user?.email),
                _isEditing
                    ? _buildEditableStringField("Home Address", homeAddressController)
                    : _buildInfoRow("Home Address", user?.homeAddress),
              ],
            ),
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
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10), // Add spacing between label and value
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Add padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Semi-transparent white background
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: Text(
                value ?? 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableStringField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
            maxLines: null,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}