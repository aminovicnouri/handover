part of 'map_bloc.dart';

@immutable
abstract class MapEvent {
  const MapEvent();
}

class InitControllerEvent implements MapEvent {
  final GoogleMapController controller;

  InitControllerEvent({required this.controller});
}

class AddMarkersEvent implements MapEvent {
  final Order? order;

  AddMarkersEvent({required this.order});
}
