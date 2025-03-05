import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/users_model.dart'; // Ensure this import path is correct
import '../provider/user_provider.dart'; // Ensure this import path is correct

class ComplaintsForm extends StatefulWidget {
  @override
  _ComplaintsFormState createState() => _ComplaintsFormState();
}

class _ComplaintsFormState extends State<ComplaintsForm> {
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
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Name: ${_nameController.text}'),
              Text('House Number: ${_houseNumberController.text}'),
              Text('Street: ${_streetController.text}'),
              Text('Subdivision: ${_subdivisionController.text}'),
              Text('Complaint Type: ${_selectedComplaintType == 'Other' ? _otherComplaintController.text : _selectedComplaintType}'),
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
      await submitComplaint();
    }
  }

  Future<void> submitComplaint() async {
    const apiUrl = 'https://baranguard.shop/API/complaintsdb.php';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: const Text('Submit a Complaint'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please fill out the form below:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _houseNumberController,
                decoration: const InputDecoration(
                  labelText: 'House Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _subdivisionController,
                decoration: const InputDecoration(
                  labelText: 'Subdivision',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedComplaintType,
                decoration: const InputDecoration(
                  labelText: 'Type of Complaint',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Noise Complaint',
                  'Waste Complaint',
                  'Loitering',
                  'Animal Complaints',
                  'Vandalism',
                  'Trespassing',
                  'Boundary Disputes',
                  'Domestic Disputes',
                  'Other', // Add "Other" option
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedComplaintType = newValue;
                    _showOtherComplaintField = newValue == 'Other'; // Show "Other" field if "Other" is selected
                  });
                },
              ),
              if (_showOtherComplaintField)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: TextField(
                    controller: _otherComplaintController,
                    decoration: const InputDecoration(
                      labelText: 'Please specify other complaint type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              const SizedBox(height: 15),
              TextField(
                controller: _contactNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _narrativeController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Narrative of Events',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Add Photo or Evidence'),
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
                    backgroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  onPressed: _confirmAndSubmit,
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
    );
  }
}