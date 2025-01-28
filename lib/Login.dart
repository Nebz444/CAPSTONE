import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For user provider management
import 'package:baranguard/provider/user_provider.dart';
import 'package:baranguard/views/baranguard_dashboard.dart'; // Import Dashboard screen
import 'package:baranguard/signup.dart'; // Import SignUp screen
import 'controller/login_controller.dart';
import 'model/users_model.dart';

class BaranguardLoginPage extends StatefulWidget {
  @override
  _BaranguardLoginPageState createState() => _BaranguardLoginPageState();
}

class _BaranguardLoginPageState extends State<BaranguardLoginPage> {
  final LoginController _loginController = LoginController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // To manage loading state

  // Login logic
  Future<void> _login() async {
    String username = _idController.text.trim();
    String password = _passwordController.text.trim();

    // Check if fields are empty
    if (username.isEmpty || password.isEmpty) {
      _showSnackbar('Username and password are required.');
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a user object
      User user = User(username: username, password: password);

      // Attempt login
      bool success = await _loginController.login(user);

      if (success) {
        // Fetch current user data
        User? currentUser = await _loginController.getUser(username);

        if (currentUser != null) {
          // Save user data to the provider
          Provider.of<UserProvider>(context, listen: false)
              .setUser(currentUser);

          // Navigate to the dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BaranguardDashboard(
                username: currentUser.username,
              ),
            ),
                (route) => false,
          );
        } else {
          _showSnackbar('Error: Unable to fetch user details.');
        }
      } else {
        _showSnackbar('Error: Incorrect username or password.');
      }
    } catch (e) {
      _showSnackbar('Error: Something went wrong. Please try again later.');
      debugPrint('Login error: $e');
    } finally {
      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show SnackBars
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // App Title
                Text(
                  'Baranguard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),

                // Username Field
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Login Button
                _isLoading
                    ? CircularProgressIndicator() // Show loading indicator
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Sign Up Link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
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
}
