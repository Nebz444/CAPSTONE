import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BusinessPermitStatusPage extends StatefulWidget {
  final int userId;

  BusinessPermitStatusPage({required this.userId});

  @override
  _BusinessPermitStatusPageState createState() => _BusinessPermitStatusPageState();
}

class _BusinessPermitStatusPageState extends State<BusinessPermitStatusPage> {
  List<dynamic> businessPermitRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusinessPermitRequests();
  }

  Future<void> fetchBusinessPermitRequests() async {
    final url1 = Uri.parse('https://manibaugparalaya.com/API/getBusinessPermit.php?user_id=${widget.userId}');
    final url2 = Uri.parse('https://manibaugparalaya.com/API/getBusinessPermit1.php?user_id=${widget.userId}');

    try {
      print("Fetching Business Permit data for user_id: ${widget.userId}");

      final response1 = await http.get(url1);
      final response2 = await http.get(url2);

      print("Response1 Status: ${response1.statusCode}");
      print("Response2 Status: ${response2.statusCode}");

      List businessPermitRequests = [];

      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        print("Response1 Data: \${json.encode(data1)}");
        if (data1 is List) businessPermitRequests.addAll(data1);
      }

      if (response2.statusCode == 200) {
        final data2 = json.decode(response2.body);
        print("Response2 Data: \${json.encode(data2)}");
        if (data2 is List) businessPermitRequests.addAll(data2);
      }

      setState(() {
        this.businessPermitRequests = businessPermitRequests;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching Business Permit requests: $error");
      setState(() => isLoading = false);
    }
  }

  Future<void> _addNote(int index, int userId, int id, String note) async {
    final url = Uri.parse('https://manibaugparalaya.com/API/note2.php');

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
          setState(() {
            businessPermitRequests[index]['note'] = note;
          });
          await fetchBusinessPermitRequests();
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
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBusinessPermitEntry(dynamic request, int index) {
    String businessName = request['business_name'] ?? 'Unknown';
    String ownerName = request['owner_name'] ?? 'Unknown';
    String houseNumber = request['house_number'] ?? 'N/A';
    String street = request['street'] ?? 'N/A';
    String subdivision = request['subdivision'] ?? 'N/A';
    String businessType = request['business_type'] ?? 'N/A';
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
                onPressed: () => _showAddNoteDialog(index, request['user_id'], id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Business Name: $businessName", style: const TextStyle(color: Colors.black)),
          Text("Owner: $ownerName", style: const TextStyle(color: Colors.black)),
          Text("Address: $houseNumber, $street, $subdivision", style: const TextStyle(color: Colors.black)),
          Text("Business Type: $businessType", style: const TextStyle(color: Colors.black)),
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
        title: const Text('Business Permit Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF154068),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : businessPermitRequests.isEmpty
            ? const Center(child: Text("No Business Permit requests found", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: businessPermitRequests.length,
          itemBuilder: (context, index) {
            return _buildBusinessPermitEntry(businessPermitRequests[index], index);
          },
        ),
      ),
    );
  }
}
