import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IndigencyStatusPage extends StatefulWidget {
  final int userId;

  IndigencyStatusPage({required this.userId});

  @override
  _IndigencyStatusPageState createState() => _IndigencyStatusPageState();
}

class _IndigencyStatusPageState extends State<IndigencyStatusPage> {
  List<dynamic> indigencyRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIndigencyRequests();
  }

  Future<void> fetchIndigencyRequests() async {
    final url1 = Uri.parse('https://manibaugparalaya.com/API/getIndigency.php?user_id=${widget.userId}');
    final url2 = Uri.parse('https://manibaugparalaya.com/API/getIndigency1.php?user_id=${widget.userId}');

    try {
      print("Fetching Indigency data for user_id: ${widget.userId}");

      // Fetch both APIs in parallel
      final response1 = await http.get(url1);
      final response2 = await http.get(url2);

      print("Response1 Status: ${response1.statusCode}");
      print("Response2 Status: ${response2.statusCode}");

      List indigencyRequests = [];

      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        print("Response1 Data: ${json.encode(data1)}");
        if (data1 is List) indigencyRequests.addAll(data1);
      }

      if (response2.statusCode == 200) {
        final data2 = json.decode(response2.body);
        print("Response2 Data: ${json.encode(data2)}");
        if (data2 is List) indigencyRequests.addAll(data2);
      }

      setState(() {
        this.indigencyRequests = indigencyRequests;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching Indigency requests: $error");
      setState(() => isLoading = false);
    }
  }

  Future<void> _addNote(int index, int userId, int id, String note) async {
    final url = Uri.parse('https://manibaugparalaya.com/API/note5.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'user_id': userId.toString(),
          'id': id.toString(),
          'note': note,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          // ✅ Update the note in the list
          setState(() {
            indigencyRequests[index]['note'] = note;
          });

          // Optionally fetch data again for accuracy
          await fetchIndigencyRequests();
        } else {
          print("❌ Failed to add note: ${responseData['message']}");
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
      }
    } catch (error) {
      print("❌ Error sending request: $error");
    }
  }

  void _showAddNoteDialog(int index, int userId, int id) {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Note"),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(hintText: "Enter note"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _addNote(index, userId, id, noteController.text);
                Navigator.pop(context); // Close dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIndigencyEntry(dynamic request, int index) {
    // Handle potential null values
    String managerName = request['managerName'] ?? 'Unknown';
    String patientName = request['patientName'] ?? 'Unknown';
    int age = request['age'] ?? 0;
    String birthday = request['birthday'] ?? 'N/A'; // Added birthday
    String houseNumber = request['houseNumber'] ?? 'N/A'; // Updated to houseNumber
    String street = request['street'] ?? 'N/A';
    String subdivision = request['subdivision'] ?? 'N/A';
    String fullAddress = "$houseNumber, $street, $subdivision";
    String purpose = request['purpose'] ?? 'N/A';
    String relation = request['relation'] ?? 'N/A';
    String civilStatus = request['civil_status'] ?? 'N/A';
    String gender = request['gender'] ?? 'N/A';
    String status = request['status'] ?? 'Pending';
    String annual_income = request['annual_income'] ?? 0; // Corrected variable name
    String dateRequested = request['created_at'] ?? 'N/A';
    String note = request['note'] ?? 'No note added';
    int id = request['id'] ?? 0; // Ensure the ID is extracted

    // Define status color based on status value
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                status.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.note_add),
                onPressed: () => _showAddNoteDialog(index, request['user_id'], id), // Pass index, user_id, and id
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Manager: $managerName", style: const TextStyle(color: Colors.black)),
          Text("Patient: $patientName", style: const TextStyle(color: Colors.black)),
          Text("Age: $age", style: const TextStyle(color: Colors.black)),
          Text("Birthday: $birthday", style: const TextStyle(color: Colors.black)), // Added birthday
          Text("Address: $fullAddress", style: const TextStyle(color: Colors.black)),
          Text("Purpose: $purpose", style: const TextStyle(color: Colors.black)),
          Text("Relation: $relation", style: const TextStyle(color: Colors.black)),
          Text("Civil Status: $civilStatus", style: const TextStyle(color: Colors.black)),
          Text("Gender: $gender", style: const TextStyle(color: Colors.black)),
          Text("Annual Income: $annual_income", style: const TextStyle(color: Colors.black)),
          Text("Date Requested: $dateRequested", style: const TextStyle(color: Colors.black)),
          Text("Note: $note", style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF154068),
      appBar: AppBar(
        title: const Text('Indigency Status', style: TextStyle(fontWeight: FontWeight.bold,  color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : indigencyRequests.isEmpty
            ? const Center(child: Text("No Indigency requests found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: indigencyRequests.length,
          itemBuilder: (context, index) {
            return _buildIndigencyEntry(indigencyRequests[index], index);
          },
        ),
      ),
    );
  }
}