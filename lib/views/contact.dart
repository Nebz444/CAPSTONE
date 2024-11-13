import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Colors.red[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ContactCard(
              provider: 'PELCO 2',
              contactNumbers: ['(045) 900-0423', '0919 059 0423'],
            ),
            ContactCard(
              provider: 'Porac',
              contactNumbers: ['+ (045) 649 - 6027'],
            ),
            ContactCard(
              provider: 'MDRRMO',
              contactNumbers: ['0929-441-6188', '0953-694-2079'],
            ),
            ContactCard(
              provider: 'BFP',
              contactNumbers: ['0909-918-7205', '0967-283-6777'],
            ),
            ContactCard(
              provider: 'PNP',
              contactNumbers: ['0998 598 5464', '0977 301 4154'],
            ),
            ContactCard(
              provider: 'PLDT',
              contactNumbers: ['0999-516-0000'],
            ),
            ContactCard(
              provider: 'Converge',
              contactNumbers: ['0953-344-6398'],
            ),
            ContactCard(
              provider: 'Water District',
              contactNumbers: ['(045) 329-3182', '436-1825'],
            ),
          ],
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final String provider;
  final List<String> contactNumbers;

  ContactCard({required this.provider, required this.contactNumbers});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 8),
            for (var number in contactNumbers)
              Text(
                'Contact: $number',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
