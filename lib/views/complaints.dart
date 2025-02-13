import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  String? _selectedComplaintType;

  Future<void> submitComplaint() async {
    final apiUrl = 'https://baranguard.shop/API/complaintsdb.php';

    // Prepare JSON data
    final complaintData = jsonEncode({
      'full_name': _nameController.text.trim(),
      'house_number': _houseNumberController.text.trim(),
      'street': _streetController.text.trim(),
      'subdivision': _subdivisionController.text.trim(),
      'complaint_type': _selectedComplaintType,
      'contact_number': _contactNumberController.text.trim(),
      'statement': _narrativeController.text.trim(),
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"}, // ✅ Corrected Content-Type
        body: complaintData,
      );

      print("API Response: ${response.body}"); // ✅ Debugging

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Complaint submitted successfully!")),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'] ?? "Failed to submit complaint.")),
        );
      }
    } catch (e) {
      print("Error: $e"); // ✅ Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
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
        title: Text('Submit a Complaint'),
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
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _houseNumberController,
                decoration: InputDecoration(
                  labelText: 'House Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _streetController,
                decoration: InputDecoration(
                  labelText: 'Street',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _subdivisionController,
                decoration: InputDecoration(
                  labelText: 'Subdivision',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedComplaintType,
                decoration: InputDecoration(
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
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _narrativeController,
                maxLines: 5,
                decoration: InputDecoration(
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
