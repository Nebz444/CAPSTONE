import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding JSON

class BarangayCertificateForm extends StatefulWidget {
  final String formType;

  BarangayCertificateForm({required this.formType});

  @override
  _BarangayCertificateFormState createState() => _BarangayCertificateFormState();
}

class _BarangayCertificateFormState extends State<BarangayCertificateForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _birthplaceController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _subdivisionController = TextEditingController();
  final TextEditingController _yearsResidedController = TextEditingController();
  final TextEditingController _otherPurposeController = TextEditingController(); // Controller for "Other" purpose

  String? _selectedPurpose = 'Local Employment'; // Default value
  bool _showOtherPurposeField = false; // Track if "Other" is selected

  int? parseInt(String value) => int.tryParse(value);

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _birthdayController.dispose();
    _birthplaceController.dispose();
    _houseNumberController.dispose();
    _streetController.dispose();
    _subdivisionController.dispose();
    _yearsResidedController.dispose();
    _otherPurposeController.dispose(); // Dispose of the "Other" controller
    super.dispose();
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
        // Format the date manually
        _birthdayController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = 'http://192.168.100.149/NEW/html/permits/permitdatabase/barangaycertificate.php';

      // Prepare form data with conditional inclusion of otherInput
      final formData = {
        'submit': '1', // Set submit to '1' for the API
        'name': _fullNameController.text,
        'age': parseInt(_ageController.text)?.toString() ?? '',
        'birthday': _birthdayController.text,
        'bplace': _birthplaceController.text,
        'housenum': _houseNumberController.text,
        'street': _streetController.text,
        'subdivision': _subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text,
        'years': parseInt(_yearsResidedController.text)?.toString() ?? '',
        'usertype': _selectedPurpose,
      };

      // Conditionally add the 'otherInput' if "Other" is selected
      if (_showOtherPurposeField) {
        formData['otherInput'] = _otherPurposeController.text;
      }

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: formData,
        );

        // Log response status and body for debugging
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Form submitted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit form. Please try again.')),
          );
        }
      } catch (e) {
        print('Error: $e'); // Print error to console
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
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
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
                  controller: _birthplaceController,
                  decoration: InputDecoration(
                    labelText: 'Birthplace',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your birthplace' : null,
                ),
                const SizedBox(height: 15),
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
                  controller: _yearsResidedController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Years Resided at Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => parseInt(value!) == null ? 'Enter valid years' : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedPurpose,
                  decoration: InputDecoration(
                    labelText: 'Purpose of Certification',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Local Employment',
                    'Oversea\'s Employment',
                    'Water Connection',
                    'Electric Connection',
                    'Loan Purposes',
                    'Senior Citizen',
                    'SSS',
                    'Other'
                  ]
                      .map((purpose) => DropdownMenuItem(
                    value: purpose,
                    child: Text(purpose),
                  ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPurpose = newValue;
                      _showOtherPurposeField = newValue == 'Other';
                    });
                  },
                ),
                if (_showOtherPurposeField) // Show this field only if "Other" is selected
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: TextFormField(
                      controller: _otherPurposeController,
                      decoration: InputDecoration(
                        labelText: 'Please specify other purpose',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please specify the purpose' : null,
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    onPressed: submitForm,
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
