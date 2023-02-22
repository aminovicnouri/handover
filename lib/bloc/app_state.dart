import 'package:flutter/foundation.dart' show immutable;
import 'package:geolocator/geolocator.dart' show Position;

@immutable
class AppState {
  final List<Position> positions;
  final bool serviceIsRunning;
  final LocationPermissionState? permissionState;

  const AppState({
    required this.positions,
    required this.serviceIsRunning,
    this.permissionState,
  });

  const AppState.empty()
      : positions = const [],
        serviceIsRunning = false,
        permissionState = null;
}

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  locationServiceDisabled,
}
