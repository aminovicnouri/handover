import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handover/model/order.dart';
import 'package:meta/meta.dart';

import '../services/geofence_service_manager.dart';

part 'map_event.dart';

part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapState.getInitial()) {
    on<InitControllerEvent>((event, emit) {
      initMapController(emit, event.controller);
      print("hhhhh aw hna ${event.order}");
      if(event.order != null) {
        addMarkers(emit, event.order!);
      }
    });

    on<AddMarkersEvent>((event, emit) {
      if(event.order != null) {
        addMarkers(emit, event.order!);
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
        markers: state.markers));
    //_initMarkers();
  }

  void updateCameraPosition(CameraPosition position) {
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position.target, zoom: position.zoom)));
  }

  void _listenToLocationChanges(Emitter<MapState> emit) {
    _geolocationSubscription = GeofenceServiceManager.instance()
        .locationStreamController
        .stream
        .listen((event) {
      updateCameraPosition(CameraPosition(
          target: LatLng(event.latitude, event.longitude), zoom: 15));
    });
  }

  @override
  Future<void> close() {
    _geolocationSubscription?.cancel();
    return super.close();
  }

  void addMarkers(Emitter<MapState> emit, Order order) {
    Marker origin = Marker(
        markerId: MarkerId(
          "${order.name}_origin",
        ),
        position: LatLng(
          order.pickupLatitude,
          order.pickupLongitude,
        ));
    Marker destination = Marker(
        markerId: MarkerId(
          "${order.name}_destination",
        ),
        position: LatLng(
          order.deliveryLatitude,
          order.deliveryLongitude,
        ));
    print("hhhhhhh select $origin");
    emit(MapState(controller: state.controller, position: state.position, markers: {origin, destination}));
  }
}
