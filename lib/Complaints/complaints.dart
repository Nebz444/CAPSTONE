import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct
import 'complaintsstatus.dart'; // Import the ComplaintsStatusPage

class ComplaintsForm extends StatefulWidget {
  @override
  _ComplaintsFormState createState() => _ComplaintsFormState();
}

class _ComplaintsFormState extends State<ComplaintsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _subdivisionController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _narrativeController = TextEditingController();
  final _otherComplaintController = TextEditingController(); // Controller for "Other" complaint type
  User? user;

  String? _selectedComplaintType;
  bool _showOtherComplaintField = false; // Track if "Other" is selected
  File? _imageFile; // To store the selected/captured image
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show a dialog to choose between camera and gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: const Text('Choose the source of the image:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source != null) {
      final XFile? pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _imageFile = File(pickedImage.path); // Convert XFile to File
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null; // Clear the selected image
    });
  }

  Future<void> _confirmAndSubmit() async {
    if (_isLoading) return; // Prevent multiple submissions

    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Complaint Type: ${_selectedComplaintType == 'Other' ? _otherComplaintController.text : _selectedComplaintType}'),
              Text('Name: ${_nameController.text}'),
              Text('House Number: ${_houseNumberController.text}'),
              Text('Street: ${_streetController.text}'),
              Text('Subdivision: ${_subdivisionController.text}'),
              Text('Contact Number: ${_contactNumberController.text}'),
              Text('Narrative: ${_narrativeController.text}'),
              if (_imageFile != null) const Text('Photo: Attached'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true); // Show loading indicator
      await submitComplaint();
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  Future<void> submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      const apiUrl = 'https://manibaugparalaya.com/API/complaintsdb.php';

      // Determine complaint type and set otherInput if necessary
      String complaintType = _selectedComplaintType == 'Other' ? _otherComplaintController.text : _selectedComplaintType ?? '';
      String? otherInput = _selectedComplaintType == 'Other' ? _otherComplaintController.text : null;

      // Prepare form data
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['full_name'] = _nameController.text.trim();
      request.fields['house_number'] = _houseNumberController.text.trim();
      request.fields['street'] = _streetController.text.trim();
      request.fields['subdivision'] = _subdivisionController.text.trim();
      request.fields['complaint_type'] = complaintType;
      request.fields['contact_number'] = _contactNumberController.text.trim();
      request.fields['statement'] = _narrativeController.text.trim();
      request.fields['user_id'] = user!.id.toString(); // Include the user_id
      if (otherInput != null) request.fields['otherInput'] = otherInput; // Include "Other" input if applicable

      // Add the image file if selected
      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', _imageFile!.path));
      }

      try {
        final response = await request.send();
        final responseString = await response.stream.bytesToString();
        print("API Response: $responseString");

        final responseBody = jsonDecode(responseString);

        if (response.statusCode == 200 && responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Complaint submitted successfully!")),
          );
          _clearForm();

          // Navigate to ComplaintsStatusPage after successful submission
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComplaintsStatusPage(userId: int.parse(user!.id.toString())),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? "Failed to submit complaint.")),
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
    _nameController.clear();
    _houseNumberController.clear();
    _streetController.clear();
    _subdivisionController.clear();
    _contactNumberController.clear();
    _narrativeController.clear();
    _otherComplaintController.clear();
    setState(() {
      _selectedComplaintType = null;
      _showOtherComplaintField = false;
      _imageFile = null; // Clear the selected image
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF174A7C), // Dark blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D56),
        centerTitle: true,
        title: const Text('Complaint Request', style: TextStyle(fontSize: 20, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // Make the back button white
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
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
                    "Complaint Form",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Complaint Type at the beginning
                buildDropdown("Complaint Type", _selectedComplaintType, [
                  'Noise Complaint',
                  'Waste Complaint',
                  'Loitering',
                  'Animal Complaints',
                  'Vandalism',
                  'Trespassing',
                  'Boundary Disputes',
                  'Domestic Disputes',
                  'Other', // Add "Other" option
                ], (newValue) {
                  setState(() {
                    _selectedComplaintType = newValue;
                    _showOtherComplaintField = newValue == 'Other'; // Show "Other" field if "Other" is selected
                  });
                }),
                if (_showOtherComplaintField)
                  buildTextField("Please specify other complaint type", _otherComplaintController),
                const SizedBox(height: 10),
                buildTextField("Name", _nameController),
                Row(
                  children: [
                    Expanded(child: buildTextField("House Number", _houseNumberController)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Street", _streetController)),
                  ],
                ),
                buildTextField("Subdivision (if any)", _subdivisionController, required: false),
                buildTextField("Contact Number", _contactNumberController, keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                const Text(
                  'Description of Complaints (Optional):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _narrativeController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: const Text('[ + Attach Image ]', style: TextStyle(color: Colors.white)),
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            height: 200, // Adjust height as needed
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    onPressed: _isLoading ? null : _confirmAndSubmit, // Disable button when loading
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

  Widget buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, bool required = true}) {
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
            ),
            keyboardType: keyboardType,
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