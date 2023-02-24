part of 'map_bloc.dart';


@immutable
abstract class MapEvent {
  const MapEvent();
}

class InitControllerEvent implements MapEvent {
  final GoogleMapController controller;
  final Order? order;

  InitControllerEvent({required this.controller, required this.order});
}

class AddMarkersEvent implements MapEvent {
  final Order? order;

  AddMarkersEvent({required this.order});
}
