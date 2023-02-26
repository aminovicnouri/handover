import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handover/model/order.dart';

import '../../services/geofence_service_manager.dart';

part 'map_event.dart';

part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapState.getInitial()) {
    on<InitControllerEvent>((event, emit) {
      initMapController(emit, event.controller);
    });

    on<AddMarkersEvent>((event, emit) {
      if (event.order != null) {
        addMarkers(emit, event.order!);
      } else {
        print("hhhhhhhhhhh");
        emit(
          MapState(
              controller: state.controller,
              position: state.position,
              markers: const {},
              circles: const {}),
        );
      }
    });
  }

  StreamSubscription? _geolocationSubscription;

  late GoogleMapController controller;

  void initMapController(
      Emitter<MapState> emit, GoogleMapController controller) {
    this.controller = controller;

    _listenToLocationChanges(emit);
    emit(MapState(
      controller: this.controller,
      position: state.position,
      markers: state.markers,
      circles: state.circles,
    ));
    //_initMarkers();
  }

  void updateCameraPosition(CameraPosition position) {
    if (state.markers.isEmpty) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: position.target, zoom: position.zoom)));
    } else {
      LatLngBounds bounds;
      try {
        bounds = LatLngBounds(
          southwest: state.markers.last.position,
          northeast: state.markers.first.position,
        );
      } catch (e) {
        bounds = LatLngBounds(
          southwest: state.markers.first.position,
          northeast: state.markers.last.position,
        );
      }
      controller.animateCamera(CameraUpdate.newLatLngBounds(
        bounds,
        100,
      ));
    }
  }

  void _listenToLocationChanges(Emitter<MapState> emit) {
    _geolocationSubscription = GeofenceServiceManager.instance()
        .locationStreamController
        .stream
        .listen((event) {
      updateCameraPosition(CameraPosition(
          target: LatLng(event.latitude, event.longitude), zoom: 10));
    });
  }

  @override
  Future<void> close() {
    _geolocationSubscription?.cancel();
    return super.close();
  }

  Future<void> addMarkers(Emitter<MapState> emit, Order order) async {
    Marker origin = Marker(
        markerId: MarkerId(
          "${order.name}_origin",
        ),
        position: LatLng(
          order.pickupLatitude,
          order.pickupLongitude,
        ));
    Circle origin_100m = Circle(
        circleId: const CircleId("origin_100m"),
        center: origin.position,
        radius: 500,
        strokeWidth: 0,
        fillColor: Colors.blue[600]!.withOpacity(.5));
    Circle origin_1km = Circle(
        circleId: const CircleId("origin_1km"),
        center: origin.position,
        radius: 5000,
        strokeWidth: 0,
        fillColor: Colors.blue[600]!.withOpacity(.3));

    Marker destination = Marker(
        markerId: MarkerId(
          "${order.name}_destination",
        ),
        position: LatLng(
          order.deliveryLatitude,
          order.deliveryLongitude,
        ));

    Circle destination_100m = Circle(
        circleId: const CircleId("destination_100m"),
        center: destination.position,
        radius: 500,
        strokeWidth: 0,
        fillColor: Colors.green[600]!.withOpacity(.5));

    Circle destination_1km = Circle(
        circleId: const CircleId("destination_1km"),
        center: destination.position,
        radius: 5000,
        strokeWidth: 0,
        fillColor: Colors.green[600]!.withOpacity(.3));
    final markers = {origin, destination};

    emit(MapState(
      controller: state.controller,
      position: state.position,
      markers: markers,
      circles: {origin_100m, origin_1km, destination_100m, destination_1km},
    ));
  }
}
