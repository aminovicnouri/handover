import 'package:geolocator/geolocator.dart';

import 'home/home_bloc.dart';

Future<LocationPermissionState> checkPermissions() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return LocationPermissionState.locationServiceDisabled;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.deniedForever) {
    return LocationPermissionState.deniedForever;
  }

  if (permission == LocationPermission.denied) {
    return LocationPermissionState.denied;
  }

  return LocationPermissionState.granted;
}

Future<bool> requestPermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    return true;
  }
  return false;
}

