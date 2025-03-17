import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart';
import '../provider/user_provider.dart';
import 'package:baranguard/formStatus/certificateStatus.dart';

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
  final _purokController = TextEditingController();
  final _yearsResidedController = TextEditingController();
  final _otherPurposeController = TextEditingController();

  String? _selectedsex = 'Male';
  String? _selectedcivil_status = 'Single';
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
              _buildConfirmationItem("Purok", _purokController.text),
              _buildConfirmationItem("Gender", _selectedsex ?? ''),
              _buildConfirmationItem("Civil Status", _selectedcivil_status ?? ''),
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
      const apiUrl = 'https://manibaugparalaya.com/API/barangay_certificate.php';

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
        'purok': _purokController.text.trim(),
        'sex': _selectedsex, // Ensure this matches the PHP backend's expected key
        'civil_status': _selectedcivil_status,
        'years': _yearsResidedController.text.trim(),
        'usertype': _selectedPurpose!,
        'user_id': user!.id.toString(),
        if (_showOtherPurposeField) 'other_specify': _otherPurposeController.text.trim(),
      };

      print("Request Payload: $formData");

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(formData),
        );

        print("Raw API Response: ${response.body}"); // Log the raw response

        if (response.body.isEmpty) {
          throw FormatException("Empty response from server");
        }

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 && responseBody['status'] == 'success') {
          _showSuccessMessage();
          _clearForm();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CertificateStatusPage(userId: int.parse(user!.id.toString())),
            ),
          );
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
    _purokController.clear();
    _yearsResidedController.clear();
    _otherPurposeController.clear();
    setState(() {
      _selectedsex = 'Male';
      _selectedcivil_status = 'Single';
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56), // Dark blue matching the design
        centerTitle: true,
        title: const Text('Barangay Certificate', style: TextStyle(fontSize: 20, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back button white
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, // Gradient starts at the top
                end: Alignment.bottomCenter, // Gradient ends at the bottom
                colors: [
                  Color(0xFF0D2D56), // Dark blue (top)
                  Color(0xFF1E5A8A), // Medium blue (middle)
                  Color(0xFF2D7BA7), // Lighter blue (bottom)
                ],
                stops: [0.0, 0.5, 1.0], // Control the transition points
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20), // Add some spacing at the top
                    _buildFormFields(isSmallScreen),
                    const SizedBox(height: 20),
                    _buildSubmitButton(isSmallScreen),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(bool isSmallScreen) {
    return Column(
      children: [
        // First Name, Middle Name, Last Name
        buildTextField("First Name", _firstNameController),
        buildTextField("Middle Name", _middleNameController, required: false),
        buildTextField("Last Name", _lastNameController),

        // House Number and Street
        Row(
          children: [
            Expanded(child: buildTextField("House Number", _houseNumberController)),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Expanded(child: buildTextField("Street", _streetController)),
          ],
        ),

        // Subdivision and Purok
        buildTextField("Subdivision (if any)", _subdivisionController, required: false),
        buildTextField("Purok", _purokController, required: false),

        // Birthday and Age
        Row(
          children: [
            Expanded(child: buildTextField("Birthday", _birthdayController,
                readOnly: true, onTap: () => _selectDate(context))),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Expanded(child: buildTextField("Age", _ageController,
                keyboardType: TextInputType.number)),
          ],
        ),

        // Birthplace
        buildTextField("Birthplace", _birthplaceController),

        // Gender and Civil Status
        Row(
          children: [
            Expanded(
              child: buildDropdown(
                "Gender",
                _selectedsex,
                ['Male', 'Female'],
                    (newValue) {
                  setState(() {
                    _selectedsex = newValue;
                  });
                },
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Expanded(
              child: buildDropdown(
                "Civil Status",
                _selectedcivil_status,
                ['Single', 'Married', 'Widowed','Annulled'],
                    (newValue) {
                  setState(() {
                    _selectedcivil_status = newValue;
                  });
                },
              ),
            ),
          ],
        ),

        // Years Resided at Address
        buildTextField("Years Resided at Address", _yearsResidedController,
            keyboardType: TextInputType.number),

        // Purpose Dropdown
        _buildPurposeDropdown(isSmallScreen),

        // Other Purpose Field (if applicable)
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