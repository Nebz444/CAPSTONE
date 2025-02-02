import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'reset_password_screen.dart';
import 'package:baranguard/Login.dart';

class RequestOTPScreen extends StatefulWidget {
  @override
  _RequestOTPScreenState createState() => _RequestOTPScreenState();
}

class _RequestOTPScreenState extends State<RequestOTPScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // Replace with your actual endpoint
  final String sendOtpUrl = 'http://192.168.100.149/dartdb/sendotp.php';

  Future<void> _requestOTP() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Email is required')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // POST request to your backend
      final response = await http.post(
        Uri.parse(sendOtpUrl),
        body: {'email': email},
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to your email')),
        );
        // Navigate to the reset password screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to send OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Enter your email to receive an OTP',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                onPressed: _requestOTP, child: Text('Request OTP')),
          ],
        ),
      ),
    );
  }
}
