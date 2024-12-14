import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safecampus/view/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'global/global_vars.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    Platform.isAndroid
        ? await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyC09D99-ooHFHfGdUT6FuhMSAG-GU3__Rg',
        appId: '1:980780633548:android:a6856b6ad3ee799a652169',
        messagingSenderId: '980780633548',
        projectId: 'indiazona-8c437',
      ),
    )
        : await Firebase.initializeApp();
  }

  // Initialize SharedPreferences
  sharedPreferences = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F1F6),
      ),
      debugShowCheckedModeBanner: false,
      home: const PermissionWrapper(),
    );
  }
}

class PermissionWrapper extends StatefulWidget {
  const PermissionWrapper({super.key});

  @override
  _PermissionWrapperState createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  @override
  void initState() {
    super.initState();
    _requestPermissions(context);
  }

  @override
  Widget build(BuildContext context) {
    return const MysplashScreen(); // Replace with your splash screen
  }

  // Function to request necessary permissions
  Future<void> _requestPermissions(BuildContext context) async {
    final locationStatus = await Permission.location.request();
    final cameraStatus = await Permission.camera.request();
    final galleryStatus = await Permission.photos.request();
    final storageStatus = await Permission.storage.request(); // Request storage permission

    // Show dialogs if permissions are denied
    if (!locationStatus.isGranted) {
     /// await _showPermissionDialog(context, 'Location', Permission.location);
    }
    if (!cameraStatus.isGranted) {
    //  await _showPermissionDialog(context, 'Camera', Permission.camera);
    }
    if (!galleryStatus.isGranted) {
     // await _showPermissionDialog(context, 'Gallery', Permission.photos);
    }
    if (!storageStatus.isGranted) { // Show dialog for storage if denied
    //  await _showPermissionDialog(context, 'Storage', Permission.storage);
    }
  }

  // Function to show a permission dialog
  Future<void> _showPermissionDialog(BuildContext context, String permissionName, Permission permission) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text('The app needs access to your $permissionName to function properly.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Re-request the permission after closing the dialog
                await permission.request();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
