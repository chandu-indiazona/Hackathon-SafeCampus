import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../global/global_vars.dart';

class CommonViewModel {

  getCurrentLocation() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    position = cPosition;
    placeMark = await placemarkFromCoordinates(cPosition.latitude, cPosition.longitude);
    Placemark placeMarkVar = placeMark![0];
    fullAddress="${placeMarkVar.subThoroughfare} ${placeMarkVar.subThoroughfare}, ${placeMarkVar.subLocality} ${placeMarkVar.locality},${placeMarkVar.subAdministrativeArea},${placeMarkVar.administrativeArea} ${placeMarkVar.postalCode},${placeMarkVar.country},";

    return fullAddress;
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 243, 138, 33),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK',
        textColor: const Color.fromARGB(255, 0, 0, 0),
        onPressed: () {},
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      elevation: 10, // Elevation for shadow
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
