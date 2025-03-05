import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct

class BarangayCertificateForm extends StatefulWidget {
  final String formType;

  BarangayCertificateForm({required this.formType});

  @override
  _BarangayCertificateFormState createState() => _BarangayCertificateFormState();
}

class _BarangayCertificateFormState extends State<BarangayCertificateForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _birthplaceController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _subdivisionController = TextEditingController();
  final _yearsResidedController = TextEditingController();
  final _otherPurposeController = TextEditingController();

  String? _selectedPurpose = 'Local Employment';
  bool _showOtherPurposeField = false;

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
              Text("Full Name: ${_fullNameController.text}"),
              Text("Age: ${_ageController.text}"),
              Text("Birthday: ${_birthdayController.text}"),
              Text("Birthplace: ${_birthplaceController.text}"),
              Text("House Number: ${_houseNumberController.text}"),
              Text("Street: ${_streetController.text}"),
              Text("Subdivision: ${_subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text}"),
              Text("Years Resided: ${_yearsResidedController.text}"),
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

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      const apiUrl = 'https://baranguard.shop/API/barangay_certificate.php';

      // Prepare form data
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['name'] = _fullNameController.text.trim();
      request.fields['age'] = _ageController.text.trim();
      request.fields['birthday'] = _birthdayController.text.trim();
      request.fields['bplace'] = _birthplaceController.text.trim();
      request.fields['housenum'] = _houseNumberController.text.trim();
      request.fields['street'] = _streetController.text.trim();
      request.fields['subdivision'] = _subdivisionController.text.trim().isEmpty
          ? 'N/A'
          : _subdivisionController.text.trim();
      request.fields['years'] = _yearsResidedController.text.trim();
      request.fields['usertype'] = _selectedPurpose ?? '';
      request.fields['user_id'] = user!.id.toString();

      if (_showOtherPurposeField) {
        request.fields['otherInput'] = _otherPurposeController.text.trim();
      }

      // Debug: Print the request payload
      print("Request Payload: ${request.fields}");

      try {
        final response = await request.send();
        final responseString = await response.stream.bytesToString();
        print("API Response: $responseString");

        final responseBody = jsonDecode(responseString);

        if (response.statusCode == 200 && responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Certificate request submitted successfully!")),
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
    _ageController.clear();
    _birthdayController.clear();
    _birthplaceController.clear();
    _houseNumberController.clear();
    _streetController.clear();
    _subdivisionController.clear();
    _yearsResidedController.clear();
    _otherPurposeController.clear();
    setState(() {
      _selectedPurpose = 'Local Employment';
      _showOtherPurposeField = false;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600; // Adjust breakpoint as needed

    return Scaffold(
      backgroundColor: const Color(0xFF174A7C), // Dark blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56),
        title: Text(widget.formType),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2D56),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Barangay Certificate Form",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField("Full Name", _fullNameController),
                Row(
                  children: [
                    Expanded(child: buildTextField("Age", _ageController, keyboardType: TextInputType.number)),
                    SizedBox(width: isSmallScreen ? 8 : 10),
                    Expanded(child: buildTextField("Birthday", _birthdayController, readOnly: true, onTap: () => _selectDate(context))),
                  ],
                ),
                buildTextField("Birthplace", _birthplaceController),
                Row(
                  children: [
                    Expanded(child: buildTextField("House Number", _houseNumberController)),
                    SizedBox(width: isSmallScreen ? 8 : 10),
                    Expanded(child: buildTextField("Street", _streetController)),
                  ],
                ),
                buildTextField("Subdivision (if any)", _subdivisionController),
                Row(
                  children: [
                    Expanded(child: buildTextField("Years Resided at Address", _yearsResidedController, keyboardType: TextInputType.number)),
                    SizedBox(width: isSmallScreen ? 8 : 10),
                    Expanded(
                      child: SizedBox(
                        width: isSmallScreen ? screenWidth * 0.4 : screenWidth * 0.3, // Constrain dropdown width
                        child: buildDropdown("Purpose of Certification", _selectedPurpose, [
                          'Local Employment',
                          'Oversea\'s Employment',
                          'Water Connection',
                          'Electric Connection',
                          'Loan Purposes',
                          'Senior Citizen',
                          'SSS',
                          'Other'
                        ], (newValue) {
                          setState(() {
                            _selectedPurpose = newValue;
                            _showOtherPurposeField = newValue == 'Other';
                          });
                        }),
                      ),
                    ),
                  ],
                ),
                if (_showOtherPurposeField)
                  buildTextField("Please specify other purpose", _otherPurposeController),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 15,
                        horizontal: isSmallScreen ? 20 : 30,
                      ),
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
                        : Text(
                      'Submit',
                      style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white),
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

  Widget buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, bool readOnly = false, VoidCallback? onTap}) {
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