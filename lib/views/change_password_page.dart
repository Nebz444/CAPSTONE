import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // For storing user ID

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  int? _userId; // Store the user ID

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load the user ID when the page initializes
  }

  // Load the user ID from SharedPreferences
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id'); // Assuming you stored the user ID as 'user_id'
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate() && _userId != null) {
      setState(() {
        _isLoading = true;
      });

      final url = Uri.parse('https://baranguard.shop/API/changepassword.php');
      final response = await http.post(
        url,
        body: {
          'user_id': _userId.toString(), // Send the user ID as a string
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        },
      );

      setState(() {
        _isLoading = false;
      });

      debugPrint("Change Password Response: ${response.body}");

      final responseData = json.decode(response.body);
      if (responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: ${responseData['message']}')),
        );
      }
    } else if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}