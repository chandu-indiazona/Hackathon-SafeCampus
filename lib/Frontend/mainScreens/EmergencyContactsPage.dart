import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsPage extends StatelessWidget {
  final List<EmergencyContact> contacts = [
    EmergencyContact(name: 'Campus Security', phone: '+911234567890'),
    EmergencyContact(name: 'Local Police', phone: '100'),
    EmergencyContact(name: 'Grievance Cell', phone: '+911234567891'),
    EmergencyContact(name: 'Counseling Helpline', phone: '+911234567892'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.phone, color: Colors.orangeAccent),
              title: Text(contact.name),
              subtitle: Text(contact.phone),
              trailing: IconButton(
                icon: Icon(Icons.call, color: Colors.green),
                onPressed: () => _makePhoneCall(contact.phone),
              ),
            ),
          );
        },
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({required this.name, required this.phone});
}
