import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BarangayID extends StatefulWidget {
  final String formType;

  BarangayID({required this.formType});

  @override
  _BarangayIDState createState() => _BarangayIDState();
}

class _BarangayIDState extends State<BarangayID> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _fullNameController = TextEditingController();
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

  bool _isLoading = false;

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

  //Confirmation
  Future<void> confirmSubmission() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("Name: ${_fullNameController.text}"),
              Text("Age: ${_ageController.text}"),
              Text("Birthday: ${_birthdayController.text}"),
              Text("Birthplace: ${_birthplaceController.text}"),
              Text("House Number: ${_houseNumberController.text}"),
              Text("Street: ${_streetController.text}"),
              Text("Subdivision: ${_subdivisionController.text.isEmpty ? 'N/A' : _subdivisionController.text}"),
              Text("Gender: ${_selectedGender ?? 'N/A'}"),
              Text("Civil Status: ${_selectedCivilStatus ?? 'N/A'}"),
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
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Confirm"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      submitForm();
    }
  }

    Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final apiUrl = 'https://baranguard.shop/API/barangay_id.php';

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
                _buildTextField(_fullNameController, 'Full Name'),
                _buildTextField(_houseNumberController, 'House Number'),
                _buildTextField(_streetController, 'Street'),
                _buildTextField(_subdivisionController, 'Subdivision'),
                _buildTextField(_ageController, 'Age', TextInputType.number),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(_birthdayController, 'Birthday (YYYY-MM-DD)'),
                  ),
                ),
                _buildDropdown('Gender', _selectedGender, ['Male', 'Female'],
                        (newValue) => setState(() => _selectedGender = newValue)),
                _buildDropdown('Civil Status', _selectedCivilStatus,
                    ['Single', 'Married', 'Widowed', 'Anulled'],
                        (newValue) => setState(() => _selectedCivilStatus = newValue)),
                _buildTextField(_birthplaceController, 'Birthplace'),
                _buildTextField(_heightController, 'Height (cm)', TextInputType.number),
                _buildTextField(_weightController, 'Weight (kg)', TextInputType.number),
                _buildTextField(_contactNumberController, 'Contact Number', TextInputType.phone),
                _buildTextField(_emergencyNumberController, 'Emergency Contact', TextInputType.phone),
                const SizedBox(height: 20),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: confirmSubmission,
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDropdown(
      String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
