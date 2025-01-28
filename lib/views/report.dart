import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  LatLng? _currentLocation; // Current location
  XFile? _imageFile; // Image file picked
  final TextEditingController _noteController = TextEditingController();
  final LatLng _targetLocation = LatLng(15.113359178687087, 120.56616699467249);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    // Request location permissions if needed
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // Fetch the current position
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
        SnackBar(content: Text('Location not available. Please try again later.')),
      );
      return;
    }

    final String note = _noteController.text.trim();
    final String? imagePath = _imageFile?.path;
    final double latitude = _currentLocation!.latitude;
    final double longitude = _currentLocation!.longitude;

    if (note.isEmpty || imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a note and upload evidence.')),
      );
      return;
    }

    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Report Submission'),
          content: Text('Do you want to submit the report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final request = http.MultipartRequest('POST', Uri.parse('http://192.168.100.149/dartdb/report.php'));
        request.fields['latitude'] = latitude.toString();
        request.fields['longitude'] = longitude.toString();
        request.fields['note'] = note;
        request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

        final response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit the report.')),
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
        title: Text('Report Location'),
      ),
      body: _currentLocation == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching location, please wait...'),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: _currentLocation, // Use the current location as the map center
                  zoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.yourapp',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 80.0,
                        height: 80.0,
                        builder: (ctx) => Icon(
                          Icons.my_location,
                          color: Colors.green,
                          size: 40.0,
                        ),
                      ),
                      Marker(
                        point: _targetLocation,
                        width: 80.0,
                        height: 80.0,
                        builder: (ctx) => Icon(
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
            SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Enter a note',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera),
              label: Text('Capture Evidence'),
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image.file(
                  File(_imageFile!.path),
                  height: 200,
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _confirmAndSubmitReport,
              child: Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}
