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

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final apiUrl = 'http://192.168.100.149/NEW/html/permits/permitdatabase/barangayid.php';

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
                    onPressed: submitForm,
                    child: const Text('Submit'),
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
