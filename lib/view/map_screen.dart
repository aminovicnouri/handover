
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../bloc/map/map_bloc.dart';

class MapScreen extends StatelessWidget {


  const MapScreen({super.key,required this.mapBloc});

  final MapBloc mapBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        bloc: mapBloc,
        builder: (context, state) {
          return GoogleMap(
            onMapCreated: (controller) {
              mapBloc.add(InitControllerEvent(controller: controller));
            },
            markers: state.markers,
            circles: state.circles,
            initialCameraPosition: state.position,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          );
        },
      ),
    );
  }
}