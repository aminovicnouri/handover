part of 'map_bloc.dart';

@immutable
class MapState {
  final GoogleMapController? controller;
  final CameraPosition position;
  final Set<Marker> markers;



  const MapState({required this.controller, required this.position, required this.markers,});

  static MapState getInitial() {
    return const MapState(controller: null, markers: {} ,position: CameraPosition(target: LatLng(25.090793, 55.146700), zoom: 13));
  }
}

