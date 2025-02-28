import 'package:baranguard/register.dart'; // Ensure this import is correct
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For user provider management
import 'package:baranguard/provider/user_provider.dart';
import 'package:baranguard/views/baranguard_dashboard.dart'; // Import Dashboard screen
import 'request_otp_screen.dart'; // Import the OTP Request screen
import 'controller/login_controller.dart';
import 'model/users_model.dart';

class BaranguardWelcomePage extends StatefulWidget {
  const BaranguardWelcomePage({super.key});

  @override
  _BaranguardWelcomePageState createState() => _BaranguardWelcomePageState();
}

class _BaranguardWelcomePageState extends State<BaranguardWelcomePage> {
  final LoginController _loginController = LoginController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showLoginForm = false;
  bool _isLoading = false; // To manage loading state

  // Login logic (unchanged)
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

      if (success = true) {
        debugPrint('Received Request');
      }

      if (success) {
        // Fetch current user data
        User? currentUser = await _loginController.getUser(username);
        debugPrint("Abot dito");

        if (currentUser != null) {
          // Save user data to the provider
          Provider.of<UserProvider>(context, listen: false)
              .setUser(currentUser);
          debugPrint("success");
          // Navigate to the dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BaranguardDashboard (),
            ),
                (route) => false,
          );
        } else {
          _showSnackbar('Error: Unable to fetch user details.');
        }
      } else {
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

  // Custom Page Route with Animation
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide from right
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
    return PopScope(
      canPop: false, // Prevent app from closing on back button
      child: Scaffold(
        backgroundColor: const Color(0xFF154C79), // Blue background
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              // Close the login form when tapping outside the container
              if (showLoginForm && mounted) {
                setState(() {
                  showLoginForm = false;
                });
              }
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Fixed Logo and Title
                    const SizedBox(height: 20), // Increased top spacing
                    const Text(
                      'Baranguard',
                      style: TextStyle(
                        fontSize: 50, // Larger font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20), // Increased spacing
                    Image.asset(
                      'lib/images/Logo.png',
                      width: MediaQuery.of(context).size.width * 0.5, // Larger logo
                      height: MediaQuery.of(context).size.width * 0.5,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20), // Increased spacing

                    // Animated Login Form or Initial Buttons
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: showLoginForm ? _buildLoginForm() : _buildInitialButtons(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Initial Buttons
  Widget _buildInitialButtons() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500), // Smooth transition
      transitionBuilder: (widget, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: widget,
          ),
        );
      },
      child: Container(
        key: const ValueKey(1),
        padding: const EdgeInsets.all(40), // Increased padding
        decoration: BoxDecoration(
          color: const Color(0xFF9AA6B2), // Gray background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Avoid excessive space
          children: [
            // Responsive Button Width
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7, // Adjust width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF154C79),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20), // Consistent button height
                ),
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      showLoginForm = true;
                    });
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 22), // Adjusted font size
                ),
              ),
            ),
            const SizedBox(height: 20), // Increased spacing

            // Register Button with Animation
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7, // Adjust width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF154C79),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20), // Consistent button height
                ),
                onPressed: () {
                  Navigator.of(context).push(_createRoute(BarangayRegistration())); // Use custom animation
                },
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontSize: 22), // Adjusted font size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Login Form
  Widget _buildLoginForm() {
    return Container(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(25), // Increased padding
      decoration: BoxDecoration(
        color: const Color(0xFF9AA6B2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8, // Prevent overflow
            ),
            child: TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20), // Increased spacing
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8, // Prevent overflow
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20), // Increased spacing
          // Centered Forgot Password
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to RequestOTPScreen with animation
                Navigator.of(context).push(_createRoute(RequestOTPScreen()));
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.white, fontSize: 18), // Larger font
              ),
            ),
          ),
          const SizedBox(height: 20), // Increased spacing
          _isLoading
              ? const CircularProgressIndicator() // Show loading indicator
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF154C79),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50), // Larger button
            ),
            onPressed: _login,
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white, fontSize: 20), // Larger font
            ),
          ),
        ],
      ),
    );
  }
}