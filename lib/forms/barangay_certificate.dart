import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart';
import '../provider/user_provider.dart';

class BarangayCertificateForm extends StatefulWidget {
  final String formType;

  const BarangayCertificateForm({required this.formType});

  @override
  _BarangayCertificateFormState createState() => _BarangayCertificateFormState();
}

class _BarangayCertificateFormState extends State<BarangayCertificateForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;
  }

  Future<void> confirmSubmission() async {
    if (_isLoading) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildConfirmationItem("First Name", _firstNameController.text),
              _buildConfirmationItem("Middle Name", _middleNameController.text),
              _buildConfirmationItem("Last Name", _lastNameController.text),
              _buildConfirmationItem("Age", _ageController.text),
              _buildConfirmationItem("Birthday", _birthdayController.text),
              _buildConfirmationItem("Birthplace", _birthplaceController.text),
              _buildConfirmationItem("House Number", _houseNumberController.text),
              _buildConfirmationItem("Street", _streetController.text),
              _buildConfirmationItem("Subdivision",
                  _subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text),
              _buildConfirmationItem("Years Resided", _yearsResidedController.text),
              _buildConfirmationItem("Purpose", _selectedPurpose == 'Other'
                  ? _otherPurposeController.text
                  : _selectedPurpose!),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Edit"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Confirm"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await submitForm();
      setState(() => _isLoading = false);
    }
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      const apiUrl = 'https://baranguard.shop/API/barangay_certificate.php';

      final Map<String, dynamic> formData = {
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': _ageController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'birthplace': _birthplaceController.text.trim(),
        'housenum': _houseNumberController.text.trim(),
        'street': _streetController.text.trim(),
        'subdivision': _subdivisionController.text.trim().isEmpty
            ? 'N/A'
            : _subdivisionController.text.trim(),
        'years': _yearsResidedController.text.trim(),
        'usertype': _selectedPurpose!,
        'user_id': user!.id.toString(),
        if (_showOtherPurposeField) 'other_specify': _otherPurposeController.text.trim(),
      };

      print("Request Payload: $formData");

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'}, // Change content type to JSON
          body: jsonEncode(formData), // Encode the form data as JSON
        );

        print("API Response: ${response.body}");
        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 && responseBody['status'] == 'success') {
          _showSuccessMessage();
          _clearForm();
        } else {
          _showErrorMessage(responseBody['message'] ?? "Failed to submit request.");
        }
      } on FormatException catch (e) {
        print("JSON Error: $e");
        _showErrorMessage("Invalid server response format.");
      } catch (e) {
        print("Error: $e");
        _showErrorMessage("An error occurred. Please try again.");
      }
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Certificate request submitted successfully!")),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearForm() {
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
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
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdayController.text =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-"
            "${pickedDate.day.toString().padLeft(2, '0')}";
        _ageController.text = (DateTime.now().year - pickedDate.year).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF174A7C),
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
                _buildFormHeader(isSmallScreen),
                const SizedBox(height: 20),
                _buildFormFields(isSmallScreen),
                const SizedBox(height: 20),
                _buildSubmitButton(isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(bool isSmallScreen) {
    return Container(
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
    );
  }

  Widget _buildFormFields(bool isSmallScreen) {
    return Column(
      children: [
        buildTextField("First Name", _firstNameController),
        buildTextField("Middle Name", _middleNameController, required: false),
        buildTextField("Last Name", _lastNameController),
        Row(
          children: [
            Expanded(child: buildTextField("Age", _ageController,
                keyboardType: TextInputType.number)),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Expanded(child: buildTextField("Birthday", _birthdayController,
                readOnly: true, onTap: () => _selectDate(context))),
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
        buildTextField("Subdivision (if any)", _subdivisionController, required: false),
        buildTextField("Years Resided at Address", _yearsResidedController,
            keyboardType: TextInputType.number),
        _buildPurposeDropdown(isSmallScreen),
        if (_showOtherPurposeField)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showOtherPurposeField ? 1 : 0,
            child: buildTextField("Please specify other purpose", _otherPurposeController),
          ),
      ],
    );
  }

  Widget _buildPurposeDropdown(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDropdown(
            "Purpose of Certification",
            _selectedPurpose,
            [
              'Local Employment',
              "Oversea's Employment",
              'Water Connection',
              'Electric Connection',
              'Loan Purposes',
              'Senior Citizen',
              'SSS',
              'Other'
            ],
                (newValue) {
              setState(() {
                _selectedPurpose = newValue;
                _showOtherPurposeField = newValue == 'Other';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isSmallScreen) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 12 : 15,
            horizontal: isSmallScreen ? 20 : 30,
          ),
        ),
        onPressed: _isLoading ? null : confirmSubmission,
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
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    bool required = true
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              suffixIcon: onTap != null
                  ? IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: onTap,
              )
                  : null,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Please select $label' : null,
        ),
      ],
    );
  }
}