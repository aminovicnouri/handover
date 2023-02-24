part of 'map_bloc.dart';

@immutable
class MapState {
  final GoogleMapController? controller;
  final CameraPosition position;
  final Set<Marker> markers;
  final Set<Circle> circles;

  const MapState(
      {required this.controller,
      required this.position,
      required this.markers,
      required this.circles});

  static MapState getInitial() {
    return const MapState(
      controller: null,
      markers: {},
      circles: {},
      position: CameraPosition(
        target: LatLng(25.090793, 55.146700),
        zoom: 13,
      ),
    );
  }
}
