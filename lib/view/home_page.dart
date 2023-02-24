import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handover/map/map_bloc.dart';

import '../bloc/app_bloc.dart';
import '../bloc/app_state.dart';
import '../bloc/bloc_event.dart';
import '../repositories/order_repository_Impl.dart';
import 'map_screen.dart';
import 'orders_bottom_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => OrderRepositoryImpl(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppBloc>(
              create: (context) =>
                  AppBloc(orderRepository: context.read<OrderRepositoryImpl>())
                    ..add(const CheckPermissions())
                    ..add(const InitialState())),
          BlocProvider<MapBloc>(create: (context) => MapBloc()),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Home Page'),
          ),
          body: BlocConsumer<AppBloc, AppState>(
            listener: (BuildContext context, AppState state) {
              if (state.showBottomSheet && !isBottomSheetVisible(context)) {
                _showMyBottomSheet(context);
              }
              if (state.currentOrder != null &&
                  context.read<MapBloc>().state.markers.isEmpty) {
                context
                    .read<MapBloc>()
                    .add(AddMarkersEvent(order: state.currentOrder));
              }
            },
            builder: (context, appState) {
              switch (appState.permissionState) {
                case LocationPermissionState.granted:
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                          'selected order: ${appState.currentOrder?.name ?? "null"}'),
                      Expanded(
                        child: MapScreen(mapBloc: context.read<MapBloc>()),
                      ),
                      GestureDetector(
                        child: Text("hdjkfhkdjfhdkjfhdkjfhdkjfhkjdhfkjdhf"),
                        onTap: () {
                          _showMyBottomSheet(context);
                        },
                      )
                    ],
                  );
                case LocationPermissionState.denied:
                  return Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<AppBloc>().add(
                              const RequestPermissions(),
                            );
                      },
                      child: const Text('Request permissions'),
                    ),
                  );
                case LocationPermissionState.deniedForever:
                  return const Center(
                    child: Text('Permissions permanently denied.'),
                  );
                case LocationPermissionState.locationServiceDisabled:
                  return const Center(
                    child: Text('Location service disabled.'),
                  );
                case null:
                  return Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<AppBloc>().add(
                              const RequestPermissions(),
                            );
                      },
                      child: const Text('Request permissions'),
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showMyBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        )),
        context: context,
        builder: (BuildContext buildContext) {
          return OrdersBottomSheet(
            selectOrder: (order) {
              context.read<AppBloc>().add(SelectOrder(order: order));
            },
          );
        });
  }

  bool isBottomSheetVisible(BuildContext context) {
    final navigator = Navigator.of(context);
    return navigator.canPop();
  }
}