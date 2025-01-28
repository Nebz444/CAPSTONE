import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  DateTime? _selectedBirthday; // Store the selected birthday date

  void _signUp() async {
    String fullName = _fullNameController.text;
    String birthday = _selectedBirthday != null ? _selectedBirthday!.toIso8601String() : '';
    String username = _usernameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String mobileNumber = _mobileNumberController.text;
    String email = _emailController.text;
    String homeAddress = _homeAddressController.text;

    // Validate passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // Send signup request
    var url = Uri.parse('http://192.168.100.149/dartdb/signup.php');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'full_name': fullName,
        'birthday': birthday,
        'username': username,
        'password': password,
        'mobile_number': mobileNumber,
        'email_address': email,
        'home_address': homeAddress,
      }),
    );

    // Handle response
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign up successful!")),
        );
        Navigator.pop(context);  // Return to login page on success
      } else if (responseBody['status'] == 'error' && responseBody['message'] == 'Username already taken') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Username already taken")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.statusCode}")),
      );
    }
  }

  // Function to show a date picker and set the selected date
  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 300,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),

                // Full Name Text Field
                _buildTextField(_fullNameController, 'Full Name'),
                SizedBox(height: 10),

                // Birthday Date Picker
                GestureDetector(
                  onTap: () => _selectBirthday(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Birthday',
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: TextEditingController(
                        text: _selectedBirthday != null
                            ? "${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}"
                            : '',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Mobile Number Text Field
                _buildTextField(_mobileNumberController, 'Mobile Number'),
                SizedBox(height: 10),

                // Email Address Text Field
                _buildTextField(_emailController, 'Email Address'),
                SizedBox(height: 10),

                // Home Address Text Field
                _buildTextField(_homeAddressController, 'Home Address'),
                SizedBox(height: 20),

                // Username Text Field
                _buildTextField(_usernameController, 'Username'),
                SizedBox(height: 10),

                // Password Text Field
                _buildTextField(_passwordController, 'Password', obscureText: true),
                SizedBox(height: 10),

                // Confirm Password Text Field
                _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true),
                SizedBox(height: 10),


                // Sign Up Button
                ElevatedButton(
                  onPressed: _signUp,  // Calls sign-up function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
