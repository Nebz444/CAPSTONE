import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firstPage.dart'; // Ensure this import is correct

class BarangayRegistration extends StatefulWidget {
  const BarangayRegistration({super.key});

  @override
  _BarangayRegistrationState createState() => _BarangayRegistrationState();
}

class _BarangayRegistrationState extends State<BarangayRegistration>
    with SingleTickerProviderStateMixin {
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
  bool _isLoading = false;
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAgreed = false;

  // Animation Controller
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Future.delayed(Duration.zero, () => _showTermsDialog());
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool agree = false;
        bool notAgree = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Center(
                child: Text(
                  "Terms of Agreement",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "By clicking 'Agree' or signing up for this service, you acknowledge that you have read, understood, and agree to be bound by these Terms of Agreement, as well as our ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showPrivacyPolicy();
                      },
                      child: const Text(
                        "Privacy Policy",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      ". If you do not agree to these terms, please do not use our application.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text("Not Agree"),
                            Checkbox(
                              value: notAgree,
                              onChanged: (value) {
                                setState(() {
                                  notAgree = value!;
                                  agree = false;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          children: [
                            const Text("Agree"),
                            Checkbox(
                              value: agree,
                              onChanged: (value) {
                                setState(() {
                                  agree = value!;
                                  notAgree = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: (agree || notAgree)
                          ? () {
                        if (agree) {
                          setState(() {
                            _termsAgreed = true;
                          });
                          Navigator.of(context).pop();
                        } else if (notAgree) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const BaranguardWelcomePage(),
                            ),
                          );
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "1. We value your privacy and are committed to protecting your personal information. "
                      "This privacy policy explains how we collect, use, and share information about you when you use our services.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  "2. Information We Collect",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]),
                ),
                Text(
                  "We may collect the following types of information:\n"
                      "- Personal identification information (name, email address, phone number)\n"
                      "- Location data (IP address, GPS data)",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  "3. How We Use Your Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]),
                ),
                Text(
                  "We use the information we collect to:\n"
                      "- Maintain a record of users in our mobile application.\n"
                      "- Facilitate the signup process for barangay forms.\n"
                      "- Communicate with you.\n"
                      "- Enable users to file complaints or reports with the barangay efficiently.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  "4. Sharing Your Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]),
                ),
                Text(
                  "We may share your information with:\n"
                      "- Service providers (to perform functions on our behalf)\n"
                      "- Legal authorities (if required by law)",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  "5. Your Choices",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]),
                ),
                Text(
                  "You have the right to:\n"
                      "- Access and update your information\n"
                      "- Opt-out of certain data collection practices\n"
                      "- Request the deletion of your data",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  "6. Security",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]),
                ),
                Text(
                  "We implement appropriate technical and organizational measures to protect your information from unauthorized access, disclosure, alteration, and destruction.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  "7. Changes to This Policy",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]),
                ),
                Text(
                  "We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on our website.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  "8. Contact Us",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]),
                ),
                Text(
                  "If you have any questions about this privacy policy, please contact us at Baranguardapp@gmail.com",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showTermsDialog();
              },
              child: Text(
                "Back to Terms",
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _signUp() async {
    if (_isLoading || !mounted || !_termsAgreed) return;

    setState(() {
      _isLoading = true;
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
        _isLoading = false;
      });
      return;
    }

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty || password.isEmpty ||
        mobileNumber.isEmpty || email.isEmpty || homeAddress.isEmpty || gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All required fields must be filled.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      var url = Uri.parse('https://manibaugparalaya.com/API/signup.php');
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

        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sign up successful!")),
          );
          Navigator.of(context).pushReplacement(_createRoute(const BaranguardWelcomePage()));
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday && mounted) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFF154C79),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Back Button
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

                  // Form Container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
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
                                          borderSide: BorderSide.none),
                                    ),
                                    items: ['Male', 'Female'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (mounted) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      }
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
                                              borderSide: BorderSide.none),
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
                              if (mounted) {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              }
                            }),
                            _buildPasswordField(controller: _confirmPasswordController, label: 'Confirm Password:', obscureText: _obscureConfirmPassword, toggleVisibility: () {
                              if (mounted) {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              }
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
                              onPressed: _isLoading ? null : _signUp,
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