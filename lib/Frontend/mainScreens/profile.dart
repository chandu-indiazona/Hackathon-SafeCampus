import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_screens/auth_screen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = '';
  String email = '';
  String phone = '';

  // Function to fetch user data from SharedPreferences
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? 'Unknown';
      email = prefs.getString('email') ?? 'Unknown';
      phone = prefs.getString('phone') ?? 'Unknown';
    });
  }

  // Function to delete the user's account
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Delete the user document from Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // Delete the user's account from Firebase Authentication
        await user.delete();

        // Navigate back to the landing or login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()), // Redirect to login/landing page
              (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deleted successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in.')),
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        // Show error if the user must reauthenticate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please re-login before deleting your account.')),
        );
      } else {
        // Generic error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch the user data when the profile page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(  // Wrap the content in SingleChildScrollView to handle smaller screens
        child: Center(  // Center the content in the middle of the screen
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
              crossAxisAlignment: CrossAxisAlignment.center,  // Center the content horizontally
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Name: $name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: $email',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Phone: $phone',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _deleteAccount(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
