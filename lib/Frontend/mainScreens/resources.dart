import 'package:flutter/material.dart';


import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatelessWidget {
  final List<Resource> resources = [
    Resource(
      title: 'Helpline Numbers',
      description: 'Contact emergency helplines for immediate assistance.',
      actionLabel: 'View',
      action: () => launchUrl(Uri.parse('https://wcdhry.gov.in/women-helpline-number-181/')),
    ),
    Resource(
      title: 'Anti-Harassment Policies',
      description: 'Learn about your rights and university policies.',
      actionLabel: 'Read',
      action: () => launchUrl(Uri.parse('https://www.aihr.com/blog/anti-harassment-policy/')),
    ),
    Resource(
      title: 'Mental Health Support',
      description: 'Access counseling services and mental health resources.',
      actionLabel: 'Contact',
      action: () => launchUrl(Uri.parse('https://www.nimh.nih.gov/health/find-help')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    resource.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: resource.action,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        resource.actionLabel,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Resource {
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback action;

  Resource({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.action,
  });
}

