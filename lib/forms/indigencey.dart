import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct

class IndigencyForm extends StatefulWidget {
  final String formType;

  const IndigencyForm({super.key, required this.formType});

  @override
  _IndigencyFormState createState() => _IndigencyFormState();
}

class _IndigencyFormState extends State<IndigencyForm> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for inputs
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _subdivisionController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _otherPurposeController = TextEditingController();

  // Dropdown selections
  String? _selectedPurpose = 'Medical and Financial'; // Default value
  bool _showOtherPurposeField = false; // Track if "Other" is selected

  // User details
  User? user;

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
    _managerNameController.dispose();
    _ageController.dispose();
    _birthdayController.dispose();
    _houseNumberController.dispose();
    _streetController.dispose();
    _subdivisionController.dispose();
    _patientNameController.dispose();
    _relationController.dispose();
    _otherPurposeController.dispose();
    super.dispose();
  }

  // Date picker for birthday
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Confirmation dialog before submission
  Future<void> confirmSubmission() async {
    // Show the confirmation dialog to the user
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("Manager Name: ${_managerNameController.text}"),
              Text("Age: ${_ageController.text}"),
              Text("Birthday: ${_birthdayController.text}"),
              Text("House Number: ${_houseNumberController.text}"),
              Text("Street: ${_streetController.text}"),
              Text("Subdivision: ${_subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text}"),
              Text("Patient Name: ${_patientNameController.text}"),
              Text("Relation: ${_relationController.text}"),
              Text("Purpose: ${_selectedPurpose == 'Other' ? _otherPurposeController.text : _selectedPurpose}"),
              if (_selectedPurpose == 'Other')
                Text("Other Input: ${_otherPurposeController.text}"), // Show "Other" input if applicable
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
      await submitForm();
    }
  }

  // Form submission function
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      const apiUrl = 'https://baranguard.shop/API/indigency_form.php';

      // Determine purpose and set otherInput if necessary
      String purpose = _selectedPurpose == 'Other' ? _otherPurposeController.text : _selectedPurpose!;
      String? otherInput = _selectedPurpose == 'Other' ? _otherPurposeController.text : null;

      // Prepare form data
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['managerName'] = _managerNameController.text.trim();
      request.fields['age'] = _ageController.text.trim();
      request.fields['birthday'] = _birthdayController.text.trim();
      request.fields['houseNumber'] = _houseNumberController.text.trim();
      request.fields['street'] = _streetController.text.trim();
      request.fields['subdivision'] = _subdivisionController.text.trim().isEmpty
          ? 'N/A'
          : _subdivisionController.text.trim();
      request.fields['patientName'] = _patientNameController.text.trim();
      request.fields['relation'] = _relationController.text.trim();
      request.fields['purpose'] = purpose;
      if (otherInput != null) request.fields['otherInput'] = otherInput; // Only include if "Other" is selected
      request.fields['user_id'] = user!.id.toString(); // Include user ID

      // Debug: Print the request payload
      print("Request Payload: ${request.fields}");

      try {
        final response = await request.send();
        final responseString = await response.stream.bytesToString();
        print("API Response: $responseString");

        final responseBody = jsonDecode(responseString);

        if (response.statusCode == 200 && responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Indigency form submitted successfully!")),
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
    _managerNameController.clear();
    _ageController.clear();
    _birthdayController.clear();
    _houseNumberController.clear();
    _streetController.clear();
    _subdivisionController.clear();
    _patientNameController.clear();
    _relationController.clear();
    _otherPurposeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text(widget.formType),
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
                const Text(
                  'Please fill out the form below:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _managerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name of the one who manages',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter the manager\'s name' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => int.tryParse(value!) == null ? 'Enter a valid age' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true, // User cannot type directly, only pick date
                  validator: (value) => value!.isEmpty ? 'Please select your birthday' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _houseNumberController,
                  decoration: const InputDecoration(
                    labelText: 'House Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter house number' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter street name' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _subdivisionController,
                  decoration: const InputDecoration(
                    labelText: 'Subdivision (if any)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name of the Patient',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter the patient\'s name' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _relationController,
                  decoration: const InputDecoration(
                    labelText: 'Relation to the Patient',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your relation to the patient' : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedPurpose,
                  decoration: const InputDecoration(
                    labelText: 'Purpose',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Medical and Financial',
                    'Medical',
                    'Financial',
                    'Burial',
                    'Correction',
                    'Senior Citizen',
                    'Public Attorney\'s Office',
                    'Scholar',
                    'Other',
                  ].map((purpose) => DropdownMenuItem(
                    value: purpose,
                    child: Text(purpose),
                  )).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPurpose = newValue;
                      _showOtherPurposeField = newValue == 'Other';
                    });
                  },
                ),
                if (_showOtherPurposeField)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: TextFormField(
                      controller: _otherPurposeController,
                      decoration: const InputDecoration(
                        labelText: 'Please specify other purpose',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_showOtherPurposeField && value!.isEmpty) {
                          return 'Please specify the purpose';
                        }
                        return null;
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                    ),
                    onPressed: confirmSubmission,
                    child: const Text(
                      'Submit',
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
}