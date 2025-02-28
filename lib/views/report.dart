import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  LatLng? _currentLocation;
  XFile? _imageFile;
  final TextEditingController _noteController = TextEditingController();
  final LatLng _targetLocation = LatLng(15.113359178687087, 120.56616699467249);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> saveReportId(int reportId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> reportIds = prefs.getStringList('user_reports') ?? [];
    reportIds.add(reportId.toString());
    await prefs.setStringList('user_reports', reportIds);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
      });
    }
  }

  Future<void> _confirmAndSubmitReport() async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available. Please try again later.')),
      );
      return;
    }

    final String note = _noteController.text.trim();
    final String? imagePath = _imageFile?.path;
    final double latitude = _currentLocation!.latitude;
    final double longitude = _currentLocation!.longitude;

    if (note.isEmpty || imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a note and upload evidence.')),
      );
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Report Submission'),
          content: const Text('Do you want to submit the report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final request = http.MultipartRequest('POST', Uri.parse('https://baranguard.shop/API/report.php'));
        request.fields['latitude'] = latitude.toString();
        request.fields['longitude'] = longitude.toString();
        request.fields['note'] = note;
        request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

        final response = await request.send();
        final responseString = await response.stream.bytesToString();
        final data = jsonDecode(responseString);

        if (response.statusCode == 200 && data['status'] == 'success') {
          // ✅ Store the report ID locally
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> reportIds = prefs.getStringList('user_reports') ?? [];
          String newReportId = data['report_id'].toString();
          reportIds.add(newReportId);
          await prefs.setStringList('user_reports', reportIds);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit the report.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Location'),
      ),
      body: _currentLocation == null
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching location, please wait...'),
          ],
        ),
      )
          : SingleChildScrollView( // ✅ Prevent Overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9, // ✅ Map scales properly
                child: FlutterMap(
                  options: MapOptions(
                    center: _currentLocation,
                    zoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.yourapp',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation!,
                          width: 80.0,
                          height: 80.0,
                          builder: (ctx) => const Icon(
                            Icons.my_location,
                            color: Colors.green,
                            size: 40.0,
                          ),
                        ),
                        Marker(
                          point: _targetLocation,
                          width: 80.0,
                          height: 80.0,
                          builder: (ctx) => const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Enter a note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera),
                label: const Text('Capture Evidence'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ClipRRect( // ✅ Prevents overflow
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imageFile!.path),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.3, // ✅ Responsive height
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _confirmAndSubmitReport,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
