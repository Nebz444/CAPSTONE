import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CedulaStatusPage extends StatefulWidget {
  final int userId;

  CedulaStatusPage({required this.userId});

  @override
  _CedulaStatusPageState createState() => _CedulaStatusPageState();
}

class _CedulaStatusPageState extends State<CedulaStatusPage> {
  List<dynamic> cedulaRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCedulaRequests();
  }

  Future<void> fetchCedulaRequests() async {
    final url1 = Uri.parse('https://manibaugparalaya.com/API/getCedula.php?user_id=${widget.userId}');
    final url2 = Uri.parse('https://manibaugparalaya.com/API/getCedula1.php?user_id=${widget.userId}');

    try {
      print("Fetching Cedula data for user_id: ${widget.userId}");

      final response1 = await http.get(url1);
      final response2 = await http.get(url2);

      print("Response1 Status: ${response1.statusCode}");
      print("Response2 Status: ${response2.statusCode}");

      List cedulaRequests = [];

      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        print("Response1 Data: ${json.encode(data1)}");
        if (data1 is List) cedulaRequests.addAll(data1);
      }

      if (response2.statusCode == 200) {
        final data2 = json.decode(response2.body);
        print("Response2 Data: ${json.encode(data2)}");
        if (data2 is List) cedulaRequests.addAll(data2);
      }

      setState(() {
        this.cedulaRequests = cedulaRequests;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching Cedula requests: $error");
      setState(() => isLoading = false);
    }
  }

  Future<void> _addNote(int index, int userId, int id, String note) async {
    final url = Uri.parse('https://manibaugparalaya.com/API/note3.php');

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
            cedulaRequests[index]['note'] = note;
          });
          await fetchCedulaRequests();
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

  Widget _buildCedulaEntry(dynamic request, int index) {
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
    int id = request['id'] ?? 0;

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
              Text(status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.note_add),
                onPressed: () => _showAddNoteDialog(index, request['user_id'], id), // Pass index, user_id, and id
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Name: $fullName", style: const TextStyle(color: Colors.black)),
          Text("Address: $fullAddress", style: const TextStyle(color: Colors.black)),
          Text("Age: $age | Gender: $gender | Status: $civilStatus", style: const TextStyle(color: Colors.black)),
          Text("Birthplace: $birthplace | Birthday: $birthday", style: const TextStyle(color: Colors.black)),
          Text("Height: $height ft | Weight: $weight kg", style: const TextStyle(color: Colors.black)),
          Text("Contact: $contactNumber | Emergency: $emergencyNumber", style: const TextStyle(color: Colors.black)),
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
        title: const Text('Cedula Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cedulaRequests.isEmpty
            ? const Center(child: Text("No Cedula requests found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: cedulaRequests.length,
          itemBuilder: (context, index) {
            return _buildCedulaEntry(cedulaRequests[index], index);
          },
        ),
      ),
    );
  }
}