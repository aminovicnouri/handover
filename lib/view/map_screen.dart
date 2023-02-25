import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../bloc/map/map_bloc.dart';

class MapScreen extends StatelessWidget {


  MapScreen({super.key,required this.mapBloc});

  final MapBloc mapBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        bloc: mapBloc,
        builder: (context, state) {
          return Column(
            children: [
              Text("markers ${state.markers.length}"),
              Expanded(child: GoogleMap(
                onMapCreated: (controller) {
                  mapBloc.add(InitControllerEvent(controller: controller));
                },
                markers: state.markers,
                circles: state.circles,
                // onCameraMove: (position) =>
                //     context.read<AppBloc>().updateMarkers(position.zoom),
                initialCameraPosition: state.position,
                myLocationEnabled: true,
              ))
            ],
          );
        },
      ),
    );
  }
}