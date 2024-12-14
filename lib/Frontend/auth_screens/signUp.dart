import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../global/global_instances.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoadingSignUp = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Initialize Firebase
  }






  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade400,
              Colors.white,
              Colors.green.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo.png',
                  width: 250,
                  height: 250,
                ),
                _buildTextFieldContainer(
                  controller: nameController,
                  hintText: 'Name',
                  icon: Icons.account_circle,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 20),
                _buildTextFieldContainer(
                  controller: emailController,
                  hintText: 'Email',
                  icon: Icons.email,
                  validator: (value) =>
                  value != null && value.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 20),
                _buildTextFieldContainer(
                  controller: phoneController,
                  hintText: 'Phone',
                  icon: Icons.phone,
                  validator: (value) =>
                  value != null && value.length >= 10 ? null : 'Enter a valid phone number',
                ),
                const SizedBox(height: 20),
                _buildTextFieldContainer(
                  controller: passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) =>
                  value != null && value.length >= 6 ? null : 'Password must be at least 6 characters',
                ),
                const SizedBox(height: 20),
                _buildTextFieldContainer(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) =>
                  value == passwordController.text ? null : 'Passwords do not match',
                ),
                const SizedBox(height: 20),


                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoadingSignUp = true;
                    });
                    await authViewModel.validateSignUpForm(
                      passwordController.text.trim(),
                      confirmPasswordController.text.trim(),
                      nameController.text.trim(),
                      emailController.text.trim(),
                      phoneController.text.trim(),
                      context,
                    );
                    setState(() {
                      isLoadingSignUp = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: isLoadingSignUp
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(255, 63, 111, 1),
                      ),
                    )
                        : Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),



                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Already a registered user?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Log In here',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldContainer({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: const Color.fromRGBO(251, 126, 24, 1.0),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          icon: Icon(icon),
        ),
        validator: validator,
      ),
    );
  }
}
