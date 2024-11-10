import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding JSON

class IndigencyForm extends StatefulWidget {
  final String formType;

  IndigencyForm({required this.formType});

  @override
  _IndigencyFormState createState() => _IndigencyFormState();
}

class _IndigencyFormState extends State<IndigencyForm> {
  final _formKey = GlobalKey<FormState>();

  // Add a controller for the "Other" purpose
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _subdivisionController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _otherPurposeController = TextEditingController(); // New controller

  String? _selectedPurpose = 'Medical and Financial'; // Default value
  bool _showOtherPurposeField = false; // Track if "Other" is selected

  int? parseInt(String value) => int.tryParse(value);

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
    _otherPurposeController.dispose(); // Dispose of the "Other" controller
    super.dispose();
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
  //

  // Submission logic (updated)
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = 'http://192.168.100.149/dartdb/indigency_form.php';

      // Determine purpose and set otherInput if necessary
      String purpose = _selectedPurpose == 'Other' ? _otherPurposeController.text : _selectedPurpose!;
      String? otherInput = _selectedPurpose == 'Other' ? _otherPurposeController.text : null;

      final formData = {
        'managerName': _managerNameController.text,
        'age': _ageController.text,
        'birthday': _birthdayController.text,
        'houseNumber': _houseNumberController.text,
        'street': _streetController.text,
        'subdivision': _subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text,
        'patientName': _patientNameController.text,
        'relation': _relationController.text,
        'purpose': purpose,
        if (otherInput != null) 'otherInput': otherInput, // Only include if "Other" is selected
        'submit': '1' // Add this line to trigger the PHP if check for submission
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/x-www-form-urlencoded"}, // Change to form URL encoded
          body: formData, // Send form data directly
        );

        if (response.statusCode == 200) {
          final responseData = response.body; // PHP will handle response; you might want to process if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Form submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit form. Please try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
                TextFormField(
                  controller: _managerNameController,
                  decoration: InputDecoration(
                    labelText: 'Name of the one who manages',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter the manager\'s name' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => parseInt(value!) == null ? 'Enter a valid age' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true, // User cannot type directly, only pick date
                  validator: (value) => value!.isEmpty ? 'Please select your birthday' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _houseNumberController,
                  decoration: InputDecoration(
                    labelText: 'House Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter house number' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(
                    labelText: 'Street',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter street name' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _subdivisionController,
                  decoration: InputDecoration(
                    labelText: 'Subdivision (if any)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _patientNameController,
                  decoration: InputDecoration(
                    labelText: 'Name of the Patient',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter the patient\'s name' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _relationController,
                  decoration: InputDecoration(
                    labelText: 'Relation to the Patient',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your relation to the patient' : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedPurpose,
                  decoration: InputDecoration(
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
                      decoration: InputDecoration(
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
}
