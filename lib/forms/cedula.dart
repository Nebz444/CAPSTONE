import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct
import 'package:baranguard/formStatus/cedulaStatus.dart'; // Ensure this import path is correct

class Cedula extends StatefulWidget {
  final String formType;

  const Cedula({required this.formType});

  @override
  _CedulaState createState() => _CedulaState();
}

class _CedulaState extends State<Cedula> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _subdivisionController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthplaceController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emergencyNumberController = TextEditingController();
  final _birthdayController = TextEditingController();

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
              Text("Age: ${_ageController.text}"),
              Text("Birthday: ${_birthdayController.text}"),
              Text("Birthplace: ${_birthplaceController.text}"),
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
      setState(() => _isLoading = true); // Show loading indicator
      await submitForm();
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      const apiUrl = 'https://manibaugparalaya.com/API/cedula.php'; // Updated API endpoint

      // Prepare form data
      final Map<String, dynamic> formData = {
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'house_number': _houseNumberController.text.trim(),
        'street': _streetController.text.trim(),
        'subdivision': _subdivisionController.text.trim().isEmpty
            ? 'N/A'
            : _subdivisionController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _selectedGender ?? 'Male''Female',
        'civil_status': _selectedCivilStatus ?? 'Single''Married''Widowed''Annulled',
        'birthplace': _birthplaceController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'height': _heightController.text.trim(),
        'weight': _weightController.text.trim(),
        'contact_number': _contactNumberController.text.trim(),
        'emergency_number': _emergencyNumberController.text.trim(),
        'user_id': user!.id.toString(),
      };

      // Debug: Print the request payload
      print("Request Payload: $formData");

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: formData,
        );

        final responseString = response.body;
        print("Raw API Response: $responseString"); // Debugging line

        // Check if the response is valid JSON
        if (responseString.trim().isEmpty) {
          throw FormatException("Empty response from server");
        }

        final responseBody = jsonDecode(responseString);

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
      } on FormatException catch (e) {
        print("JSON Decode Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid response from the server. Please try again.")),
        );
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
    _ageController.clear();
    _birthplaceController.clear();
    _heightController.clear();
    _weightController.clear();
    _contactNumberController.clear();
    _emergencyNumberController.clear();
    _birthdayController.clear();
    setState(() {
      _selectedGender = 'Male';
      _selectedCivilStatus = 'Single';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdayController.text =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        _ageController.text = (DateTime.now().year - pickedDate.year).toString();
      });
    }
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
                    Expanded(child: buildTextField("House Number", _houseNumberController)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Street", _streetController)),
                  ],
                ),
                buildTextField("Subdivision (if any)", _subdivisionController, required: false),
                Row(
                  children: [
                    Expanded(child: buildTextField("Birthday", _birthdayController, readOnly: true, onTap: () => _selectDate(context))),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Age", _ageController, keyboardType: TextInputType.number)),
                  ],
                ),
                buildTextField("Birthplace", _birthplaceController),
                Row(
                  children: [
                    Expanded(child: buildDropdown("Gender", _selectedGender, ['Male', 'Female'], (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    })),
                    const SizedBox(width: 10),
                    Expanded(child: buildDropdown("Civil Status", _selectedCivilStatus, ['Single', 'Married', 'Widowed', 'Annulled'], (newValue) {
                      setState(() {
                        _selectedCivilStatus = newValue;
                      });
                    })),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField("Height (cm)", _heightController, keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Weight (kg)", _weightController, keyboardType: TextInputType.number)),
                  ],
                ),
                buildTextField("Contact Number", _contactNumberController, keyboardType: TextInputType.phone),
                buildTextField("Emergency Contact", _emergencyNumberController),
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