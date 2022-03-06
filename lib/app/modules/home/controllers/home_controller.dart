import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart';

class HomeController extends GetxController {
  RxBool isLoaded = false.obs;
  RxBool hasError = false.obs;
  final mapCNT = MapController();
  RxDouble currentZoom = 15.0.obs;
  RxDouble maxZoom = 18.0.obs;
  RxDouble minZoom = 1.0.obs;
  RxDouble markerSize = 20.0.obs;
  RxBool liveUpdate = false.obs;
  RxBool _permission = false.obs;
  RxString serviceError = ''.obs;
  LocationData? currentLocation;
  final PopupController popupLayerController = PopupController();

  RxList<Marker> markers = RxList<Marker>();

  // final Location _locationService = Location();
  @override
  void onInit() {
    super.onInit();
    // initLocationService();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  zoomIn(double zoom) {
    double cZoom = currentZoom.value;
    if (cZoom.isLowerThan(maxZoom.value)) {
      currentZoom.value += zoom;
      print.call(currentZoom.value);
      mapCNT.move(mapCNT.center, currentZoom.value);
    }
  }

  zooOut(double zoom) {
    double cZoom = currentZoom.value;
    if (cZoom.isGreaterThan(minZoom.value)) {
      currentZoom.value -= zoom;
      print.call(currentZoom.value);
      mapCNT.move(mapCNT.center, currentZoom.value);
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      hasError.value = true;
      serviceError.value = 'Location services are disabled.';
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        hasError.value = true;
        serviceError.value = 'Location permissions are denied';
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      hasError.value = true;
      serviceError.value =
          'Location permissions are permanently denied, we cannot request permissions.';

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    hasError.value = false;

    return await Geolocator.getCurrentPosition();
  }

  resetLocation() {
    mapCNT.rotate(0);
    mapCNT.move(mapCNT.center, 15);
  }

  // Random Marker
  LatLng getRandomLocation(LatLng point, int radius) {
    //This is to generate 10 random points
    double x0 = point.latitude;
    double y0 = point.longitude;

    Random random = Random();

    // Convert radius from meters to degrees
    double radiusInDegrees = radius / 111000;

    double u = random.nextDouble();
    double v = random.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double x = w * cos(t);
    double y = w * sin(t) * 1.75;

    // Adjust the x-coordinate for the shrinking of the east-west distances
    double newX = x / sin(y0);

    double foundLatitude = newX + x0;
    double foundLongitude = y + y0;
    LatLng randomLatLng = LatLng(foundLatitude, foundLongitude);

    return randomLatLng;
  }

  getListOfPosition(int number, Position position, int radius) {
    for (int i = 0; i < number; i++) {
      final latLng = getRandomLocation(
          LatLng(position.latitude, position.longitude), radius);
      markers.add(randomMarker(latLng.latitude, latLng.longitude));
    }
  }

  userMarker(double latitude, double longitude) {
    return Marker(
      point: LatLng(latitude, longitude),
      height: 48,
      width: 48,
      builder: (context) {
        return Icon(
          Icons.pin_drop,
          color: Colors.black,
          size: markerSize.value,
        );
      },
    );
  }

  randomMarker(double latitude, double longitude) {
    return Marker(
      point: LatLng(latitude, longitude),
      height: 48,
      width: 48,
      builder: (context) {
        return Icon(
          Icons.person,
          color: Colors.red,
          size: markerSize.value,
        );
      },
    );
  }

  createAllMarker(Position position) {
    markers = RxList<Marker>();
    markers.add(userMarker(position.latitude, position.longitude));
    getListOfPosition(4, position, 100);
  }

  Future<String> decodeAddressByLatLng(Marker position) async {
    return await placemarkFromCoordinates(
            position.point.latitude, position.point.longitude)
        .then((value) {
      Placemark address = value.first;
      return address.country! + " " + address.street.toString();
    });
  }
}
