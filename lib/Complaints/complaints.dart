import 'dart:convert';
import 'package:flutter/material.dart';
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
  User? user;

  String? _selectedComplaintType;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    user = Provider.of<UserProvider>(context, listen: false).user;
  }

  Future<void> submitComplaint() async {
    const apiUrl = 'https://baranguard.shop/API/complaintsdb.php';

    // Prepare form data
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['full_name'] = _nameController.text.trim();
    request.fields['house_number'] = _houseNumberController.text.trim();
    request.fields['street'] = _streetController.text.trim();
    request.fields['subdivision'] = _subdivisionController.text.trim();
    request.fields['complaint_type'] = _selectedComplaintType ?? '';
    request.fields['contact_number'] = _contactNumberController.text.trim();
    request.fields['statement'] = _narrativeController.text.trim();
    request.fields['user_id'] = user!.id.toString(); // Include the user_id

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
    setState(() {
      _selectedComplaintType = null;
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
                  'Domestic Disputes'
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedComplaintType = newValue;
                  });
                },
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
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  onPressed: submitComplaint,
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