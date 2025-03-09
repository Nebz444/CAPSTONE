import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  void _showTermsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return TermsModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Terms and Privacy Modal")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showTermsModal(context),
          child: Text("Show Terms"),
        ),
      ),
    );
  }
}

class TermsModal extends StatefulWidget {
  @override
  _TermsModalState createState() => _TermsModalState();
}

class _TermsModalState extends State<TermsModal> {
  bool _agreed = false;
  bool _showPrivacyPolicy = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _showPrivacyPolicy ? _privacyPolicyView() : _termsView(),
          ),
        ],
      ),
    );
  }

  Widget _termsView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Terms of Agreement",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "By clicking 'Agree' or signing up, you acknowledge that you have read and agree to our Terms of Agreement and Privacy Policy.",
          textAlign: TextAlign.center,
        ),
        TextButton(
          onPressed: () {
            setState(() => _showPrivacyPolicy = true);
          },
          child: Text("Privacy Policy", style: TextStyle(decoration: TextDecoration.underline)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text("Not Agree"),
                Checkbox(
                  value: !_agreed,
                  onChanged: (value) {
                    setState(() => _agreed = false);
                  },
                ),
              ],
            ),
            Column(
              children: [
                Text("Agree"),
                Checkbox(
                  value: _agreed,
                  onChanged: (value) {
                    setState(() => _agreed = true);
                  },
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _agreed
              ? () {
            Navigator.of(context).pop();
          }
              : null,
          child: Text("Continue"),
        ),
      ],
    );
  }

  Widget _privacyPolicyView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Privacy Policy",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "We value your privacy and commit to protecting your information. This policy explains how we collect, use, and share your data.",
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() => _showPrivacyPolicy = false);
          },
          child: Text("Back to Terms"),
        ),
      ],
    );
  }
}