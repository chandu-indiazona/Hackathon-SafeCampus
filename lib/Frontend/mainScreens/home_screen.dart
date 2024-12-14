import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:safecampus/Frontend/mainScreens/profile.dart';
import 'package:safecampus/Frontend/mainScreens/reportIncident.dart';
import 'package:safecampus/Frontend/mainScreens/resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_screens/auth_screen.dart';
import '../splashScreen/splash_screen.dart';
import 'EmergencyContactsPage.dart';
import 'community.dart';
import 'complaintHistory.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // For getting location
import 'package:permission_handler/permission_handler.dart'; // For handling permissions
import 'package:safecampus/Frontend/mainScreens/resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'EmergencyContactsPage.dart';
import 'community.dart';
import 'complaintHistory.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Bottom navigation items
  final List<Widget> _pages = [
    DashboardPage(),
    ResourcesPage(),
    CommunityPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Dashboard', 'Resources', 'Community', 'Profile'][_selectedIndex],
          style: TextStyle(fontFamily: "Noto", fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
        automaticallyImplyLeading: false, // Ensures no back arrow appears
        actions: [
          IconButton(
            icon: Icon(Icons.call,
              color: Colors.green,
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  EmergencyContactsPage()),
              );

            },
          ),


          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully.')),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MysplashScreen()),
                      (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error logging out: $e')),
                );
              }
            },
          ),
        ],
      ),



      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
            tooltip: 'Go to Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Resources',
            tooltip: 'View Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
            tooltip: 'Join Community Discussions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            tooltip: 'Manage Your Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),

    );
  }
}






class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-aligned welcome text and logo
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                '   Welcome to SafeCampus!',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Image.asset(
              'assets/logo.png', // Replace with your actual path to logo.png
              height: 100,
            ),
          ],
        ),

        // Center-aligned SOS button
        Center(
          child: ElevatedButton(
            onPressed: () async {
              // Check for location permissions
              PermissionStatus status = await Permission.location.request();
              if (status.isGranted) {
                try {
                  // Get the current location
                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );

                  // Retrieve user data from SharedPreferences
                  SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
                  String? userName = sharedPreferences.getString("name");
                  String? userPhone = sharedPreferences.getString("phone");

                  if (userName == null || userPhone == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User details not found locally!')),
                    );
                    return;
                  }

                  // Format the current timestamp
                  String timestamp = DateFormat("yyyy-MM-dd'T'HH:mm:ssZ")
                      .format(DateTime.now());

                  // Build the Google Maps link
                  String googleMapsUrl = Uri.encodeFull(
                    'https://www.google.com/maps?q=${position.latitude},${position.longitude}',
                  );

                  // Optional: You can also add extra information to the link (userName, phone, timestamp)
                  String detailedUrl = Uri.encodeFull(
                    'https://www.google.com/maps?q=${position.latitude},${position.longitude}&author=$userName&content=Help%20me!&phone=$userPhone&timestamp=$timestamp',
                  );

                  // Save the SOS message with additional details to Firestore
                  await FirebaseFirestore.instance.collection('posts').add({
                    'google_maps_url': googleMapsUrl, // Save the Google Maps URL
                    'author': userName, // Save the name
                    'phone': userPhone, // Save the phone number
                    'content': 'Help me!', // Content of the message
                    'timestamp': FieldValue.serverTimestamp(), // Save the timestamp
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('SOS message sent with location!')),
                  );
                } catch (e) {
                  print('Error posting SOS message: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send SOS message!')),
                  );
                }
              } else {
                // Handle the case where location permission is denied
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location permission is required!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(50),
              backgroundColor: Colors.red, // SOS button color
              elevation: 10, // Adds a shadow for prominence
            ),
            child: Text(
              'SOS',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Bottom-aligned dashboard cards
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Report Incident Card
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    icon: Icons.report,
                    title: 'Report Incident',
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReportIncidentPage()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 20), // Space between cards
                // Track Complaints Card
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    icon: Icons.history,
                    title: 'Track Complaints',
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ComplaintHistoryPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required IconData icon, required String title, required Color color, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: color,
        child: Container(
          padding: EdgeInsets.all(20),
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
