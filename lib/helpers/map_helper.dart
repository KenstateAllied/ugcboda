// lib/helpers/map_helper.dart
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ride_share/utils/constants/colors.dart';
import 'package:ride_share/controllers/map_controller.dart';
// import 'package:geolocator/geolocator.dart';

class MapHelper {
  // show map in fullscreen
  static Future<void> showFullScreenMap(BuildContext context) async {
    MapController mapController = Get.find<MapController>();
    // Call the getUserLocation method from MapController
    await mapController.getUserLocation(); // Ensure location is fetched

    Get.to(
      () => FullScreenMapView(
        latitude: mapController.latitude.value,
        longitude: mapController.longitude.value,
        isUsingDefaultLocation: mapController.isUsingDefaultLocation.value,
      ),
      transition: Transition.downToUp,
      duration: Duration(milliseconds: 1500),
    );
  }
}

class FullScreenMapView extends StatelessWidget {
  final double latitude;
  final double longitude;
  final bool isUsingDefaultLocation;

  const FullScreenMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.isUsingDefaultLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Stack(
          children: [
              FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: 17,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ride_share',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(latitude, longitude),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          Get.showSnackbar(GetSnackBar(
                            backgroundColor: Colors.transparent,
                            duration: Duration(seconds: 7),
                            messageText: AwesomeSnackbarContent(
                              title: 'You popped me!',
                              message: isUsingDefaultLocation
                                  ? 'Uasin Gishu, Kenya'
                                  : 'The pin shows your current location',
                              messageTextStyle: TextStyle(fontSize: 16.0),
                              contentType: ContentType.help,
                            ),
                          ));
                        },
                        child: Icon(LineIcons.mapPin, color: Colors.red, size: 34),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // button to exit fullscreen
            Positioned(
              top: 60,
              right: 16,
              child: IconButton.filled(
                tooltip: 'Exit fullscreen map',
                style: fullscreenBtnButtonStyle(),
                icon: Icon(Icons.fullscreen_exit, color: kIconSecondaryColor),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle fullscreenBtnButtonStyle() {
    return ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.white),
      elevation: WidgetStatePropertyAll(15.0),
      shadowColor: WidgetStatePropertyAll(kSecondaryColor),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }
}
