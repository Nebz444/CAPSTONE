import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct
import 'package:baranguard/formStatus/indigencyStatus.dart';

class IndigencyForm extends StatefulWidget {
  final String formType;

  const IndigencyForm({required this.formType});

  @override
  _IndigencyFormState createState() => _IndigencyFormState();
}

class _IndigencyFormState extends State<IndigencyForm> {
  final _formKey = GlobalKey<FormState>();
  final _managerNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _subdivisionController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _relationController = TextEditingController();
  final _otherPurposeController = TextEditingController();
  final _annualIncomeController = TextEditingController(); // Added annual income field

  String? _selectedPurpose;
  bool _showOtherPurposeField = false;
  String? _selectedGender = 'Male'; // Added gender field
  String? _selectedCivilStatus = 'Single'; // Added civil status field

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
    _annualIncomeController.dispose(); // Dispose annual income controller
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
        _birthdayController.text =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        _ageController.text = (DateTime.now().year - pickedDate.year).toString();
      });
    }
  }

  // Confirmation dialog before submission
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
              Text("Manager Name: ${_managerNameController.text}"),
              Text("Age: ${_ageController.text}"),
              Text("Birthday: ${_birthdayController.text}"),
              Text("House Number: ${_houseNumberController.text}"),
              Text("Street: ${_streetController.text}"),
              Text("Subdivision: ${_subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text}"),
              Text("Patient Name: ${_patientNameController.text}"),
              Text("Relation: ${_relationController.text}"),
              Text("Gender: $_selectedGender"),
              Text("Civil Status: $_selectedCivilStatus"),
              Text("Annual Income: ${_annualIncomeController.text}"),
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
      setState(() => _isLoading = true); // Show loading indicator
      await submitForm();
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  // Form submission function
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      const apiUrl = 'https://manibaugparalaya.com/API/indigency_form.php';

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
      request.fields['gender'] = _selectedGender ?? 'Male'; // Add gender
      request.fields['civil_status'] = _selectedCivilStatus ?? 'Single'; // Add civil status
      request.fields['annual_income'] = _annualIncomeController.text.trim(); // Add annual income
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IndigencyStatusPage(userId: int.parse(user!.id.toString())),
            ),
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
    _annualIncomeController.clear(); // Clear annual income field
    setState(() {
      _selectedGender = 'Male';
      _selectedCivilStatus = 'Single';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    "Indigency Form",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField("Name of the one who manages", _managerNameController),
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
                    Expanded(child: buildTextField("Name of the Patient", _patientNameController)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildDropdown(
                        "Relation to the Patient",
                        _relationController.text.isEmpty ? null : _relationController.text,
                        [
                          'Myself',
                          'Spouse',
                          'Mother',
                          'Father',
                          'Sibling',
                          'Brother',
                          'Sister',
                          'Grandmother',
                          'Grandfather',
                          'Son',
                          'Daughter',
                          'Relative',
                        ],
                            (newValue) {
                          setState(() {
                            _relationController.text = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                buildTextField("Annual Income", _annualIncomeController, keyboardType: TextInputType.number), // Add annual income field
                buildDropdown("Purpose", _selectedPurpose, [
                  'Medical and Financial',
                  'Medical',
                  'Financial',
                  'Student Assistance',
                  'Food And Financial Assistance',
                  'Food Assistance',
                  'Other',
                ], (newValue) {
                  setState(() {
                    _selectedPurpose = newValue;
                    _showOtherPurposeField = newValue == 'Other';
                  });
                }),
                if (_showOtherPurposeField)
                  buildTextField("Please specify other purpose", _otherPurposeController),
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