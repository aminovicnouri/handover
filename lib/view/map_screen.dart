import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handover/model/order.dart';
import '../map/map_bloc.dart';

class MapScreen extends StatelessWidget {


  MapScreen({super.key,required this.order});

  final Order? order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => MapBloc(),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Column(
            children: [
              Text("markers ${state.markers.length}"),
              Expanded(child: GoogleMap(
                onMapCreated: (controller) {
                  context
                      .read<MapBloc>()
                      .add(InitControllerEvent(controller: controller, order: order));
                },
                markers: state.markers,
                // onCameraMove: (position) =>
                //     context.read<AppBloc>().updateMarkers(position.zoom),
                initialCameraPosition: state.position,
                myLocationEnabled: true,
              ))
            ],
          );
        },
      ),
      ),
    );
  }
}