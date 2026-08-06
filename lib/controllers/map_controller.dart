// lib/controllers/map_controller.dart
import 'dart:async';
import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapController extends GetxController {
  // Eldoret is the county headquarters and provides a useful local map
  // centre whenever the device location is unavailable.
  static const double uasinGishuLatitude = -0.5143;
  static const double uasinGishuLongitude = 35.2698;

  var latitude = uasinGishuLatitude.obs;
  var longitude = uasinGishuLongitude.obs;
  var destinationLatitude = 0.0.obs;
  var destinationLongitude = 0.0.obs;
  var destinationName = ''.obs;
  var hasDestination = false.obs;
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

  Future<void> searchDestination(String destination) async {
    final query = destination.trim();
    if (query.isEmpty) {
      hasDestination.value = false;
      destinationName.value = '';
      return;
    }

    isLoading(true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&limit=1&q=${Uri.encodeQueryComponent(query)}',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'ride_share_app',
        'Accept-Language': 'en',
      });

      if (response.statusCode != 200) {
        throw 'Unable to search destination.';
      }

      final results = json.decode(response.body) as List<dynamic>;
      if (results.isEmpty) {
        throw 'Destination not found.';
      }

      final first = results.first as Map<String, dynamic>;
      destinationLatitude.value = double.tryParse(first['lat']?.toString() ?? '') ?? uasinGishuLatitude;
      destinationLongitude.value = double.tryParse(first['lon']?.toString() ?? '') ?? uasinGishuLongitude;
      destinationName.value = query;
      hasDestination.value = true;
    } catch (e) {
      hasDestination.value = false;
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Colors.transparent,
        duration: Duration(seconds: 7),
        messageText: AwesomeSnackbarContent(
          title: 'Search failed',
          message: '$e',
          contentType: ContentType.failure,
        ),
      ));
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
