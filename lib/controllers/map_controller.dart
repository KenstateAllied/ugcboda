// lib/controllers/map_controller.dart
import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class MapController extends GetxController {
  // Eldoret is the county headquarters and provides a useful local map
  // centre whenever the device location is unavailable.
  static const double uasinGishuLatitude = -0.5143;
  static const double uasinGishuLongitude = 35.2698;

  var latitude = uasinGishuLatitude.obs;
  var longitude = uasinGishuLongitude.obs;
  var isLoading = false.obs;
  var isUsingDefaultLocation = true.obs;

  @override
  void onInit() {
    super.onInit();
    getUserLocation();
  }

  // Method to fetch user's current location
  Future<void> fetchLocation() async {
    isLoading(true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      isUsingDefaultLocation.value = false;
    } on TimeoutException catch (_) {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        latitude.value = lastPosition.latitude;
        longitude.value = lastPosition.longitude;
        isUsingDefaultLocation.value = false;
      } else {
        latitude.value = uasinGishuLatitude;
        longitude.value = uasinGishuLongitude;
        isUsingDefaultLocation.value = true;
        throw 'Unable to fetch current location. Using default location.';
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw 'Location services disabled! Showing Uasin Gishu instead.';
      }

      isLoading(true);
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await fetchLocation();
      } else if (permission == LocationPermission.denied) {
        latitude.value = uasinGishuLatitude;
        longitude.value = uasinGishuLongitude;
        isUsingDefaultLocation.value = true;
        throw 'Location permissions are denied';
      } else if (permission == LocationPermission.deniedForever) {
        latitude.value = uasinGishuLatitude;
        longitude.value = uasinGishuLongitude;
        isUsingDefaultLocation.value = true;
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }
    } catch (e) {
      // display error message in a snackbar
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Colors.transparent,
        duration: Duration(seconds: 7),
        messageText: AwesomeSnackbarContent(
          title: 'Oops!',
          message: '$e',
          contentType: ContentType.failure,
        ),
      ));
    } finally {
      isLoading(false);
    }
  }
}
