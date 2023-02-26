import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math' as math;

import '../model/order.dart';
import '../notifications/local_notification_service.dart';

class GeofenceServiceManager  {
  GeofenceServiceManager._sharedInstance();

  static final GeofenceServiceManager _shared =
      GeofenceServiceManager._sharedInstance();

  factory GeofenceServiceManager.instance() => _shared;

  StreamController<Geofence> controller = BehaviorSubject();

  final _activityStreamController = StreamController<Activity>();

 // final geofenceStreamController = StreamController<Geofence>();

  final locationStreamController = StreamController<Location>();

  Geofence? operationGeofence;

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
    LocalNotificationService.showNotificationWithPayload(id: math.Random().nextInt(100), title: geofence.id, body: geofence.status.name, payload: "");
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    controller.sink.add(geofence);
  }

  void updateGeofences(List<Geofence> geofences) {
    _geofenceService.clearGeofenceList();
    if(geofences.isNotEmpty) {
      operationGeofence = geofences.first;
      _geofenceService.addGeofenceList(geofences);
    }
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

  void start() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start().catchError(_onError);
    });
  }

  void stopGeofencing() {
    _geofenceService.stop();
  }

  bool isRunningService() {
    return _geofenceService.isRunningService;
  }
}
