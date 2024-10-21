import 'package:flutter/material.dart';
import 'package:baranguard/views/baranguard_dashboard.dart';  // Import the dashboard screen
import 'controller/login_controller.dart';
import 'main.dart';
import 'model/users_model.dart';

void main() {
  runApp(MyApp());
}

class BaranguardLoginPage extends StatefulWidget {
  @override
  _BaranguardLoginPageState createState() => _BaranguardLoginPageState();
}

class _BaranguardLoginPageState extends State<BaranguardLoginPage> {
  final LoginController _loginController = LoginController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    User user = User(
      username: _idController.text,
      password: _passwordController.text,
    );

    bool success = await _loginController.login(user);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BaranguardDashboard(username: user.username),  // Navigate to dashboard on success
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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

              // ID Text Field
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'ID:',
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Password Text Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password:',
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
              ElevatedButton(
                onPressed: _login,  // Calls login function
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Sign up Text
              GestureDetector(
                onTap: () {
                  // Navigate to sign up page
                },
                child: Text(
                  'sign up',
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
    );
  }
}
