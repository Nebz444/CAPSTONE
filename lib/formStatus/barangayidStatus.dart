import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BarangayIDStatusPage extends StatefulWidget {
  final int userId;

  BarangayIDStatusPage({required this.userId});

  @override
  _BarangayIDStatusPageState createState() => _BarangayIDStatusPageState();
}

class _BarangayIDStatusPageState extends State<BarangayIDStatusPage> {
  List<dynamic> barangayIDRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBarangayIDRequests();
  }

  Future<void> fetchBarangayIDRequests() async {
    final url1 = Uri.parse(
        'https://manibaugparalaya.com/API/getBarangayID.php?user_id=${widget
            .userId}');
    final url2 = Uri.parse(
        'https://manibaugparalaya.com/API/getBarangayID1.php?user_id=${widget
            .userId}');

    try {
      print("Fetching Barangay ID data for user_id: ${widget.userId}");

      // Fetch both APIs in parallel
      final response2 = await http.get(url1);
      final response1 = await http.get(url2);

      print("Response1 Status: ${response1.statusCode}");
      print("Response2 Status: ${response2.statusCode}");

      List barangayIDRequests = [];

      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        print("Response1 Data: ${json.encode(data1)}");
        if (data1 is List) barangayIDRequests.addAll(data1);
      }

      if (response2.statusCode == 200) {
        final data2 = json.decode(response2.body);
        print("Response2 Data: ${json.encode(data2)}");
        if (data2 is List) barangayIDRequests.addAll(data2);
      }

      setState(() {
        this.barangayIDRequests = barangayIDRequests;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching Barangay ID requests: $error");
      setState(() => isLoading = false);
    }
  }

  Future<void> _addNote(int index, int userId, int id, String note) async {
    final url = Uri.parse('https://manibaugparalaya.com/API/note.php');

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
            barangayIDRequests[index]['note'] = note;
          });

          // Optionally fetch data again for accuracy
          await fetchBarangayIDRequests();
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


  Widget _buildBarangayIDEntry(dynamic request, int index) {
    // Extracting values from request, handling potential nulls
    String firstName = request['first_name'] ?? 'Unknown';
    String middleName = request['middle_name'] ?? 'N/A';
    String lastName = request['last_name'] ?? 'Unknown';
    String fullName = "$firstName $middleName $lastName";

    String houseNumber = request['house_number'] ?? 'N/A';
    String street = request['street'] ?? 'N/A';
    String subdivision = request['subdivision'] ?? 'N/A';
    String fullAddress = "$houseNumber, $street, $subdivision";

    int age = request['age'] ?? 0;
    String gender = request['gender'] ?? 'N/A';
    String civilStatus = request['civil_status'] ?? 'N/A';
    String birthplace = request['birthplace'] ?? 'N/A';
    String height = request['height']?.toString() ?? 'N/A';
    String weight = request['weight']?.toString() ?? 'N/A';

    String contactNumber = request['contact_number'] ?? 'N/A';
    String emergencyNumber = request['emergency_number'] ?? 'N/A';
    String birthday = request['birthday'] ?? 'N/A';
    String dateRequested = request['created_at'] ?? 'N/A';
    String status = request['status'] ?? 'pending';
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
              Text(status.toUpperCase(), style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.note_add),
                onPressed: () =>
                    _showAddNoteDialog(index, request['user_id'],
                        id), // Pass index, user_id, and id
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Name: $fullName", style: const TextStyle(color: Colors.black)),
          Text("Address: $fullAddress",
              style: const TextStyle(color: Colors.black)),
          Text("Age: $age | Gender: $gender | Status: $civilStatus",
              style: const TextStyle(color: Colors.black)),
          Text("Birthplace: $birthplace | Birthday: $birthday",
              style: const TextStyle(color: Colors.black)),
          Text("Height: $height ft | Weight: $weight kg",
              style: const TextStyle(color: Colors.black)),
          Text("Contact: $contactNumber | Emergency: $emergencyNumber",
              style: const TextStyle(color: Colors.black)),
          Text("Date Requested: $dateRequested",
              style: const TextStyle(color: Colors.black)),
          Text("Note: $note", style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D2D56), // Dark blue (top)
            Color(0xFF1E5A8A), // Medium blue (middle)
            Color(0xFF2D7BA7), // Lighter blue (bottom)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Make Scaffold background transparent
        appBar: AppBar(
          title: const Text(
            'Barangay ID Status',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          // Make AppBar background transparent
          elevation: 0,
          // Remove shadow
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white), // White loading indicator
            ),
          )
              : barangayIDRequests.isEmpty
              ? const Center(
            child: Text(
              "No Barangay ID requests found",
              style: TextStyle(color: Colors.white),
            ),
          )
              : ListView.builder(
            itemCount: barangayIDRequests.length,
            itemBuilder: (context, index) {
              return _buildBarangayIDEntry(barangayIDRequests[index], index);
            },
          ),
        ),
      ),
    );
  }
}