import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct
import 'package:baranguard/formStatus/cedulaStatus.dart';

class CedulaForm extends StatefulWidget {
  final String formType;

  const CedulaForm({required this.formType});

  @override
  _CedulaFormState createState() => _CedulaFormState();
}

class _CedulaFormState extends State<CedulaForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _subdivisionController = TextEditingController();
  final _contactNumberController = TextEditingController();

  String? _selectedGender = 'Male';
  String? _selectedCivilStatus = 'Single';

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
              Text("First Name: ${_firstNameController.text}"),
              Text("Middle Name: ${_middleNameController.text}"),
              Text("Last Name: ${_lastNameController.text}"),
              Text("House Number: ${_houseNumberController.text}"),
              Text("Street: ${_streetController.text}"),
              Text("Subdivision: ${_subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text}"),
              Text("Gender: $_selectedGender"),
              Text("Civil Status: $_selectedCivilStatus"),
              Text("Contact Number: ${_contactNumberController.text}"),
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

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      const apiUrl = 'https://manibaugparalaya.com/API/cedula.php';

      // Prepare form data as a JSON object
      final Map<String, dynamic> formData = {
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'house_number': _houseNumberController.text.trim(),
        'street': _streetController.text.trim(),
        'subdivision': _subdivisionController.text.trim().isEmpty
            ? 'N/A'
            : _subdivisionController.text.trim(),
        'gender': _selectedGender ?? 'Male',
        'civil_status': _selectedCivilStatus ?? 'Single',
        'contact_number': _contactNumberController.text.trim(),
        'user_id': user!.id.toString(),
      };

      try {
        print("Submitting form to $apiUrl...");
        print("Form Data: ${jsonEncode(formData)}");

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'}, // Set content type to JSON
          body: jsonEncode(formData), // Encode the data as JSON
        );

        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 && responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cedula request submitted successfully!")),
          );
          _clearForm();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CedulaStatusPage(userId: int.parse(user!.id.toString())),
            ),
          );
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
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
    _houseNumberController.clear();
    _streetController.clear();
    _subdivisionController.clear();
    _contactNumberController.clear();
    setState(() {
      _selectedGender = 'Male';
      _selectedCivilStatus = 'Single';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF174A7C), // Dark blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    "Cedula Form",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField("First Name", _firstNameController),
                buildTextField("Middle Name", _middleNameController, required: false),
                buildTextField("Last Name", _lastNameController),
                Row(
                  children: [
                    Expanded(child: buildTextField("House Number", _houseNumberController, keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Street", _streetController)),
                  ],
                ),
                buildTextField("Subdivision (if any)", _subdivisionController, required: false),
                Row(
                  children: [
                    Expanded(child: buildDropdown("Gender", _selectedGender, ['Male', 'Female'], (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    })),
                    const SizedBox(width: 10),
                    Expanded(child: buildDropdown("Civil Status", _selectedCivilStatus, ['Single', 'Married', 'Widowed', 'Anulled'], (newValue) {
                      setState(() {
                        _selectedCivilStatus = newValue;
                      });
                    })),
                  ],
                ),
                buildTextField("Contact Number", _contactNumberController, keyboardType: TextInputType.phone),
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

  Widget buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, bool readOnly = false, VoidCallback? onTap, bool required = true}) {
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
              suffixIcon: onTap != null ? IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: onTap,
              ) : null,
            ),
            keyboardType: keyboardType,
            readOnly: readOnly,
            validator: (value) {
              if (required && (value == null || value.isEmpty)) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
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
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}