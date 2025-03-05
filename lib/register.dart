import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firstPage.dart'; // Ensure this import is correct

class BarangayRegistration extends StatefulWidget {
  const BarangayRegistration({super.key});

  @override
  _BarangayRegistrationState createState() => _BarangayRegistrationState();
}

class _BarangayRegistrationState extends State<BarangayRegistration> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  DateTime? _selectedBirthday;
  bool _isLoading = false; // Track loading state
  String? _selectedGender; // Track selected gender
  bool _obscurePassword = true; // Track password visibility
  bool _obscureConfirmPassword = true; // Track confirm password visibility

  void _signUp() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    String lastName = _lastNameController.text.trim();
    String firstName = _firstNameController.text.trim();
    String middleName = _middleNameController.text.trim();
    String suffix = _suffixController.text.trim();
    String birthday = _selectedBirthday != null ? _selectedBirthday!.toIso8601String() : '';
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String mobileNumber = _mobileNumberController.text.trim();
    String email = _emailController.text.trim();
    String homeAddress = _homeAddressController.text.trim();
    String gender = _selectedGender ?? '';

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      return;
    }

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty || password.isEmpty ||
        mobileNumber.isEmpty || email.isEmpty || homeAddress.isEmpty || gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All required fields must be filled.")),
      );
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      return;
    }

    try {
      var url = Uri.parse('https://baranguard.shop/API/signup.php');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'first_name': firstName,
          'middle_name': middleName.isNotEmpty ? middleName : null,
          'last_name': lastName,
          'suffix': suffix.isNotEmpty ? suffix : null,
          'birthday': birthday,
          'username': username,
          'password': password,
          'mobile_number': mobileNumber,
          'email_address': email,
          'home_address': homeAddress,
          'gender': gender,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        print("Response: $responseBody");

        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sign up successful!")),
          );
          // Smooth sliding transition to the first page
          Navigator.of(context).pushReplacement(_createRoute(const BaranguardWelcomePage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error during sign-up: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

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

  // Custom route for sliding transition
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide from right to left
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154C79), // Background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Back Button (Fixed Position)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(_createRoute(const BaranguardWelcomePage()));
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Container for the form (Gray background)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],  //0xFF9AA6B2 if color is not good change it to this
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Baranguard',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF154C79),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(controller: _firstNameController, label: 'First Name:'),
                        _buildTextField(controller: _lastNameController, label: 'Last Name:'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(controller: _middleNameController, label: 'Middle Name:'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: ['Male', 'Female'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _suffixController, label: 'Suffix:')),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectBirthday(context),
                                child: AbsorbPointer(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Birthdate',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
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
                            ),
                          ],
                        ),
                        _buildTextField(controller: _mobileNumberController, label: 'Mobile Number:'),
                        _buildTextField(controller: _emailController, label: 'Email Address:'),
                        _buildMultilineTextField(controller: _homeAddressController, label: 'Complete Address:'),
                        const SizedBox(height: 20),
                        _buildTextField(controller: _usernameController, label: 'Username:'),
                        _buildPasswordField(controller: _passwordController, label: 'Password:', obscureText: _obscurePassword, toggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        }),
                        _buildPasswordField(controller: _confirmPasswordController, label: 'Confirm Password:', obscureText: _obscureConfirmPassword, toggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        }),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          ),
                          onPressed: _isLoading ? null : _signUp, // Disable button when loading
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Register',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String label, required bool obscureText, required VoidCallback toggleVisibility}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildMultilineTextField({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}