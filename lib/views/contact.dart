import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // For Clipboard

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Hotlines',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactPage(),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9AA6B2),
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text(
          'Emergency Hotlines',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: const [
            ContactItem(provider: 'PELCO 2', contact: '(045) 900-0423'),
            ContactItem(provider: 'Porac', contact: '+ (045) 649 - 6027'),
            ContactItem(provider: 'MDRRMO', contact: '0929-441-6188'),
            ContactItem(provider: 'BFP', contact: '0909-918-7205'),
            ContactItem(provider: 'PNP', contact: '0998 598 5464'),
            ContactItem(provider: 'PLDT', contact: '0999-516-0000'),
            ContactItem(provider: 'Converge', contact: '0953-344-6398'),
            ContactItem(provider: 'Water District', contact: '(045) 329-3182'),
          ],
        ),
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  final String provider;
  final String contact;

  const ContactItem({super.key, required this.provider, required this.contact});

  Future<void> _makeCall(BuildContext context, String number) async {
    // Clean the phone number by removing special characters
    String cleanNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri url = Uri.parse('tel:$cleanNumber');

    print('Attempting to call: $cleanNumber');

    try {
      // Check if the device can handle the tel: URL scheme
      if (await canLaunchUrl(url)) {
        print('Launching call...');
        await launchUrl(url);
      } else {
        print('Could not launch $url');
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error making call: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Unable to make a call. Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Copy the number to the clipboard
                Clipboard.setData(ClipboardData(text: cleanNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Number copied to clipboard')),
                );
                Navigator.pop(context);
              },
              child: const Text('Copy Number'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => _makeCall(context, contact),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        contact,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}