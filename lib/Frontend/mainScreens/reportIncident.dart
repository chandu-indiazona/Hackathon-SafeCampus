import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for user UID
import 'package:permission_handler/permission_handler.dart';

import 'complaintHistory.dart';

class ReportIncidentPage extends StatefulWidget {
  @override
  _ReportIncidentPageState createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  String? _incidentType;
  String? _location;
  String? _description;
  String? _otherIncidentType; // For storing the "Other" text when selected
  String? _otherLocation; // For storing "Other" location text
  XFile? _imageFile; // Variable to hold the selected image file
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // To track image upload status

  // Culprit details
  String? _culpritName;
  String? _culpritDescription;

  // Function to pick image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  // Function to upload image to Firebase Storage
  Future<String> uploadImage(File myImageFile) async {
    try {
      storageRef.Reference reference = storageRef.FirebaseStorage.instance.ref().child("incidents");
      storageRef.UploadTask uploadTask = reference.child(DateTime.now().millisecondsSinceEpoch.toString() + ".jpg").putFile(myImageFile);
      storageRef.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  // Function to store complaint details in Firestore with a new random UID
  Future<void> storeComplaintDetails(String imageUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get current user's UID

      if (user != null) {
        // Create a new complaint document with a random ID in 'complaints' collection
        CollectionReference complaints = FirebaseFirestore.instance.collection('complaints');

        // Generate a new random UID for each complaint document
        String complaintId = FirebaseFirestore.instance.collection('complaints').doc().id;

        // Update the incident type and location based on 'Other' selection
        String finalIncidentType = _incidentType == 'Other' ? _otherIncidentType ?? 'Other' : _incidentType ?? '';
        String finalLocation = _location == 'Other' ? _otherLocation ?? 'Other' : _location ?? '';

        await complaints.doc(complaintId).set({
          'studentUid': user.uid,         // Store student's UID
          'email': user.email,             // Store student's email
          'incidentType': finalIncidentType, // Store the selected or custom incident type
          'location': finalLocation,       // Store the selected or custom location
          'description': _description,
          'culpritName': _culpritName,
          'culpritDescription': _culpritDescription,
          'imageUrl': imageUrl,           // Store the uploaded image URL
          'status': 'unresolved',         // Set initial status as 'unresolved'
          'timestamp': FieldValue.serverTimestamp(), // Store the time of submission
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint reported successfully!')),
        );

        // Navigate to ComplaintHistoryPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ComplaintHistoryPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in!')),
        );
      }
    } catch (e) {
      print("Error saving complaint: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Incident'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(  // Wrap the body in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Incident Type
                Text(
                  'Incident Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Montserrat"),
                ),
                DropdownButtonFormField<String>(
                  value: _incidentType,
                  onChanged: (value) {
                    setState(() {
                      _incidentType = value;
                      if (value != 'Other') {
                        _otherIncidentType = null; // Reset Other field
                      }
                    });
                  },
                  items: [
                    'Verbal Abuse',
                    'Sexual Harassment',
                    'Bullying',
                    'Cyber Harassment',
                    'Discrimination',
                    'Other' // Added "Other" option
                  ]
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select Incident Type',
                  ),
                  validator: (value) =>
                  value == null ? 'Please select an incident type' : null,
                ),
                SizedBox(height: 16),
                if (_incidentType == 'Other') // Show text field if "Other" is selected
                  TextFormField(
                    onChanged: (value) {
                      _otherIncidentType = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Please specify incident type',
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please specify' : null,
                  ),
                SizedBox(height: 16),

                // Location
                Text(
                  'Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<String>(
                  value: _location,
                  onChanged: (value) {
                    setState(() {
                      _location = value;
                      if (value != 'Other') {
                        _otherLocation = null; // Reset Other field
                      }
                    });
                  },
                  items: [
                    'Office',
                    'Home',
                    'School',
                    'Library',
                    'Online',
                    'Other' // Added "Other" option
                  ]
                      .map((loc) => DropdownMenuItem(
                    value: loc,
                    child: Text(loc),
                  ))
                      .toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select Location',
                  ),
                  validator: (value) =>
                  value == null ? 'Please select a location' : null,
                ),
                SizedBox(height: 16),
                if (_location == 'Other') // Show text field if "Other" is selected
                  TextFormField(
                    onChanged: (value) {
                      _otherLocation = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Please specify location',
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please specify' : null,
                  ),
                SizedBox(height: 16),

                // Description (Optional)
                Text(
                  'Description (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    _description = value;
                  },
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Provide additional details if necessary',
                  ),
                ),
                SizedBox(height: 16),

                // Culprit Details Section
                Text(
                  'Culprit Details (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    _culpritName = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name of the culprit (if known)',
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  onChanged: (value) {
                    _culpritDescription = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Description of the culprit (optional)',
                  ),
                ),
                SizedBox(height: 16),

                // Image Picker Section
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: _imageFile == null
                        ? Center(child: Text('Tap to select image'))
                        : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 16),

                // Submit Button
                ElevatedButton(


                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // If there's an image, upload it
                      String imageUrl = '';
                      if (_imageFile != null) {
                        setState(() {
                          _isLoading = true;
                        });
                        imageUrl = await uploadImage(File(_imageFile!.path));
                        setState(() {
                          _isLoading = false;
                        });
                      }

                      // Store complaint details in Firestore
                      await storeComplaintDetails(imageUrl);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
