import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding JSON

class CedulaForm extends StatefulWidget {
  final String formType;

  CedulaForm({required this.formType});

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
        _birthdayController.text =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Form submission function

// Modify the submitForm function
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = 'http://192.168.100.149/NEW/html/permits/permitdatabase/barangaycedula.php';

      final formData = {
        'full_name': _fullNameController.text,
        'house_number': _houseNumberController.text,
        'street': _streetController.text,
        'subdivision': _subdivisionController.text,
        'age': _ageController.text,
        'gender': _selectedGender,
        'civil_status': _selectedCivilStatus,
        'birthplace': _birthplaceController.text,
        'birthday': _birthdayController.text,
        'height': _heightController.text,
        'weight': _weightController.text,
        'contact_number': _contactNumberController.text,
        'emergency_number': _emergencyNumberController.text,
        'submit': '1',
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
                const Text(
                  'Please fill out the form below:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _houseNumberController,
                  decoration: InputDecoration(
                    labelText: 'House Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your house number' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(
                    labelText: 'Street',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your street' : null,
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
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
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
                      decoration: InputDecoration(
                        labelText: 'Birthday (YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter your birthday' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
                    labelText: 'Birthplace',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your birthplace' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => parseDouble(value!) == null ? 'Enter valid height' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => parseDouble(value!) == null ? 'Enter valid weight' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _contactNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter contact number' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emergencyNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
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
