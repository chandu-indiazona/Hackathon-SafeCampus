import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safecampus/global/global_instances.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/mainScreens/home_screen.dart';
import 'common_view_model.dart';
import 'package:safecampus/global/global_vars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class AuthViewModel {
  Future<void> validateSignUpForm(
      String password,
      String confirmPassword,
      String name,
      String email,
      String phone,

      BuildContext context) async {
    if (password == confirmPassword) {
      if (name.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          phone.isNotEmpty ) {

        commonViewModel.showSnackBar("Please Wait..", context);
        User? currentFirebaseUser =
        await createUserInFirebaseAuth(email, password, context);

        if (currentFirebaseUser != null) {
          await saveUserDataToFirestore(currentFirebaseUser, name, email,
              password, phone);
          Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreen()));
          commonViewModel.showSnackBar("Account Created Successfully", context);
        }
      } else {
        commonViewModel.showSnackBar("Please fill all fields", context);
        FirebaseAuth.instance.signOut();
        return;
      }
    } else {
      commonViewModel.showSnackBar("Passwords do not match", context);
      FirebaseAuth.instance.signOut();
      return;
    }
  }

  Future<User?> createUserInFirebaseAuth(
      String email, String password, BuildContext context) async {
    User? currentFirebaseUser;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      currentFirebaseUser = userCredential.user;
    } catch (e) {
      commonViewModel.showSnackBar(e.toString(), context);
    }

    return currentFirebaseUser;
  }

  Future<void> saveUserDataToFirestore(
      User currentFirebaseUser,
      String name,
      String email,
      String password,
      String phone)

  async {
    await FirebaseFirestore.instance
        .collection("students")
        .doc(currentFirebaseUser.uid)
        .set({
      "uid": currentFirebaseUser.uid,
      "email": email,
      "name": name,
      "phone": phone,
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("uid", currentFirebaseUser.uid);
    await sharedPreferences.setString("email", email);
    await sharedPreferences.setString("name", name);
    await sharedPreferences.setString("phone", phone);
  }


  validateSignInForm(String email, String password, BuildContext context) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      commonViewModel.showSnackBar("Checking credentials...", context);
      User? currentFirebaseUser = await loginUser(email, password, context);

      if (currentFirebaseUser != null) {
        String? userRole = await getUserRole(currentFirebaseUser);

        if (userRole == "student") {
          await readDataFromFirestoreAndSetDataLocally(currentFirebaseUser, context);
          Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
        } else {
          commonViewModel.showSnackBar("Invalid credentials for Student.", context);
          FirebaseAuth.instance.signOut();
        }
      }
    } else {
      commonViewModel.showSnackBar("Password and Email are required", context);
      return;
    }
  }

  Future<User?> loginUser(String email, String password, BuildContext context) async {
    User? currentFirebaseUser;

    try {
      UserCredential valueAuth = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      currentFirebaseUser = valueAuth.user;
    } catch (error) {
      commonViewModel.showSnackBar(error.toString(), context);
      return null;
    }

    if (currentFirebaseUser == null) {
      await FirebaseAuth.instance.signOut();
      return null;
    }

    return currentFirebaseUser;
  }

  Future<String?> getUserRole(User currentFirebaseUser) async {
    DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection("students")
        .doc(currentFirebaseUser.uid)
        .get();

    if (studentSnapshot.exists) {
      return "student";
    }



    return null;
  }

  readDataFromFirestoreAndSetDataLocally(User? currentFirebaseUser, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("students")
        .doc(currentFirebaseUser!.uid)
        .get()
        .then((dataSnapshot) async {
      if (dataSnapshot.exists) {

          await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
          await sharedPreferences!.setString("email", dataSnapshot.data()!["email"]);
          await sharedPreferences!.setString("name", dataSnapshot.data()!["name"]);
          await sharedPreferences!.setString("phone", dataSnapshot.data()!["phone"]);

      } else {
        commonViewModel.showSnackBar("This Student record does not exist", context);
        FirebaseAuth.instance.signOut();
        return;
      }
    });
  }
}

