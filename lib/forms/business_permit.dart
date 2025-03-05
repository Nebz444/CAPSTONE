import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct

class BusinessForm extends StatefulWidget {
  final String formType;

  const BusinessForm({super.key, required this.formType});

  @override
  _BusinessFormState createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for inputs
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _subdivisionController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();

  User? user;
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;
  }

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _houseNumberController.dispose();
    _streetController.dispose();
    _subdivisionController.dispose();
    _businessTypeController.dispose();
    super.dispose();
  }

  // Confirmation dialog before submission for business permit form
  Future<void> confirmSubmission() async {
    if (_isLoading) return; // Prevent multiple submissions

    // Show the confirmation dialog to the user
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("Business Name: ${_businessNameController.text}"),
              Text("Owner Name: ${_ownerNameController.text}"),
              Text("House Number: ${_houseNumberController.text}"),
              Text("Street: ${_streetController.text}"),
              Text("Subdivision: ${_subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text}"),
              Text("Business Type: ${_businessTypeController.text}"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Edit"),
            onPressed: () => Navigator.of(context).pop(false), // Close dialog and allow editing
          ),
          TextButton(
            child: const Text("Confirm"),
            onPressed: () => Navigator.of(context).pop(true), // Close dialog and proceed with submission
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true); // Show loading indicator
      await submitForm();
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  // Form submission function
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      const apiUrl = 'https://baranguard.shop/API/business_permit_form.php';

      // Prepare form data
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['business_name'] = _businessNameController.text.trim();
      request.fields['owner_name'] = _ownerNameController.text.trim();
      request.fields['house_number'] = _houseNumberController.text.trim();
      request.fields['street'] = _streetController.text.trim();
      request.fields['subdivision'] = _subdivisionController.text.trim().isEmpty
          ? 'N/A'
          : _subdivisionController.text.trim();
      request.fields['business_type'] = _businessTypeController.text.trim();
      request.fields['user_id'] = user!.id.toString();

      // Debug: Print the request payload
      print("Request Payload: ${request.fields}");

      try {
        final response = await request.send();
        final responseString = await response.stream.bytesToString();
        print("API Response: $responseString");

        final responseBody = jsonDecode(responseString);

        if (response.statusCode == 200 && responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Business permit request submitted successfully!")),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? "Failed to submit request.")),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    }
  }

  void _clearForm() {
    _businessNameController.clear();
    _ownerNameController.clear();
    _houseNumberController.clear();
    _streetController.clear();
    _subdivisionController.clear();
    _businessTypeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF174A7C), // Dark blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2D56),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Business Permit",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField("Business Name", _businessNameController),
                buildTextField("Name of Business Owner", _ownerNameController),
                Row(
                  children: [
                    Expanded(child: buildTextField("House Number", _houseNumberController)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Street", _streetController)),
                  ],
                ),
                buildTextField("Subdivision (if any)", _subdivisionController),
                buildTextField("Type of Business", _businessTypeController),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    onPressed: _isLoading ? null : confirmSubmission, // Disable button when loading
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
                      'Confirm',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Smaller padding
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}