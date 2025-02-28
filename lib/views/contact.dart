import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final Uri url = Uri.parse('tel:$number');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Confirmation'),
        content: Text('Do you want to call $number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
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
