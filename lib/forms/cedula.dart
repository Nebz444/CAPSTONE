import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct

class CedulaForm extends StatefulWidget {
  final String formType;

  const CedulaForm({super.key, required this.formType});

  @override
  _CedulaFormState createState() => _CedulaFormState();
}

class _CedulaFormState extends State<CedulaForm> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for inputs
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _subdivisionController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthplaceController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emergencyNumberController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  // Dropdown selections
  String? _selectedGender = 'Male'; // Default value
  String? _selectedCivilStatus = 'Single'; // Default value

  // User details
  User? user;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  // Fetch user details from the provider
  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;
    print("Fetched User ID: ${user?.id}"); // Debug print
  }

  // Helper to parse integers and doubles
  int? parseInt(String value) => int.tryParse(value);
  double? parseDouble(String value) => double.tryParse(value);

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    _fullNameController.dispose();
    _houseNumberController.dispose();
    _streetController.dispose();
    _subdivisionController.dispose();
    _ageController.dispose();
    _birthplaceController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _contactNumberController.dispose();
    _emergencyNumberController.dispose();
    _birthdayController.dispose();
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
              Text("Full Name: ${_fullNameController.text}"),
              Text("Age: ${_ageController.text}"),
              Text("Birthday: ${_birthdayController.text}"),
              Text("Birthplace: ${_birthplaceController.text}"),
              Text("House Number: ${_houseNumberController.text}"),
              Text("Street: ${_streetController.text}"),
              Text("Subdivision: ${_subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text}"),
              Text("Gender: $_selectedGender"),
              Text("Civil Status: $_selectedCivilStatus"),
              Text("Height: ${_heightController.text} cm"),
              Text("Weight: ${_weightController.text} kg"),
              Text("Contact Number: ${_contactNumberController.text}"),
              Text("Emergency Contact: ${_emergencyNumberController.text}"),
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
      const apiUrl = 'https://baranguard.shop/API/cedula.php';

      // Prepare form data
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['full_name'] = _fullNameController.text.trim();
      request.fields['house_number'] = _houseNumberController.text.trim();
      request.fields['street'] = _streetController.text.trim();
      request.fields['subdivision'] = _subdivisionController.text.trim().isEmpty
          ? 'N/A'
          : _subdivisionController.text.trim();
      request.fields['age'] = _ageController.text.trim();
      request.fields['gender'] = _selectedGender ?? 'Male';
      request.fields['civil_status'] = _selectedCivilStatus ?? 'Single';
      request.fields['birthplace'] = _birthplaceController.text.trim();
      request.fields['birthday'] = _birthdayController.text.trim();
      request.fields['height'] = _heightController.text.trim();
      request.fields['weight'] = _weightController.text.trim();
      request.fields['contact_number'] = _contactNumberController.text.trim();
      request.fields['emergency_number'] = _emergencyNumberController.text.trim();
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
            const SnackBar(content: Text("Cedula form submitted successfully!")),
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
    _fullNameController.clear();
    _houseNumberController.clear();
    _streetController.clear();
    _subdivisionController.clear();
    _ageController.clear();
    _birthplaceController.clear();
    _heightController.clear();
    _weightController.clear();
    _contactNumberController.clear();
    _emergencyNumberController.clear();
    _birthdayController.clear();
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
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _houseNumberController,
                  decoration: const InputDecoration(
                    labelText: 'House Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your house number' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your street' : null,
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
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => parseInt(value!) == null ? 'Enter a valid age' : null,
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _birthdayController,
                      decoration: const InputDecoration(
                        labelText: 'Birthday (YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please select your birthday' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female']
                      .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                      .toList(),
                  onChanged: (newValue) => setState(() => _selectedGender = newValue),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedCivilStatus,
                  decoration: const InputDecoration(
                    labelText: 'Civil Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Single', 'Married', 'Widowed', 'Annulled']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (newValue) => setState(() => _selectedCivilStatus = newValue),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _birthplaceController,
                  decoration: const InputDecoration(
                    labelText: 'Birthplace',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your birthplace' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => parseDouble(value!) == null ? 'Enter valid height' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => parseDouble(value!) == null ? 'Enter valid weight' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _contactNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter contact number' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emergencyNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'In case of Emergency',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter emergency contact' : null,
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