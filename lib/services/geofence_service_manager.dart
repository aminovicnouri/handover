import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handover/notifications/local_notification_service.dart';

class GeofenceServiceManager {
  GeofenceServiceManager._sharedInstance();

  static final GeofenceServiceManager _shared =
      GeofenceServiceManager._sharedInstance();

  factory GeofenceServiceManager.instance() => _shared;

  final _activityStreamController = StreamController<Activity>();

  final geofenceStreamController = StreamController<Geofence>();

  final locationStreamController = StreamController<Location>();

  // Create a [GeofenceService] instance and set options.
  final _geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: true,
      printDevLog: true,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {

    LocalNotificationService.showNotificationWithPayload(id: 111, title: geofence.id, body: geofence.status.name, payload: "");
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    geofenceStreamController.sink.add(geofence);
  }

  // This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');
    locationStreamController.sink.add(location);
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  void start(List<Marker> markers) {
    final geofenceList = markers
        .map((e) => Geofence(
              id: e.markerId.value,
              latitude: e.position.latitude,
              longitude: e.position.longitude,
              radius: [
                GeofenceRadius(id: '${e.markerId.value}_100m', length: 100),
                GeofenceRadius(id: '${e.markerId.value}_1000m', length: 1000),
              ],
            ))
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(geofenceList).catchError(_onError);
    });
  }

  void stopGeofencing() {
    _geofenceService.stop();
  }

  bool isRunningService() {
    return _geofenceService.isRunningService;
  }

}
