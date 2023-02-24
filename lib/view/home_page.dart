import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_bloc.dart';
import '../bloc/app_state.dart';
import '../bloc/bloc_event.dart';
import '../repositories/order_repository_Impl.dart';
import 'map_screen.dart';
import 'my_bottom_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => OrderRepositoryImpl(),
      child: BlocProvider(
        create: (context) => AppBloc(orderRepository: context.read<OrderRepositoryImpl>())..add(const CheckPermissions()),

        child: Scaffold(
          appBar: AppBar(
            title: const Text('Home Page'),
          ),
          body: BlocBuilder<AppBloc, AppState>(
            builder: (context, appState) {
              switch (appState.permissionState) {
                case LocationPermissionState.granted:
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.read<AppBloc>().add(
                                !appState.serviceIsRunning
                                    ? const StartLocationService()
                                    : const StopLocationService(),
                              );
                        },
                        child: !appState.serviceIsRunning
                            ? const Text('Start location service')
                            : const Text('Stop location service'),
                      ),
                      Text('selected order: ${appState.currentOrder?.name ?? "null"}'),
                      Expanded(
                        child: MapScreen(order: appState.currentOrder,),
                      ),
                      GestureDetector(
                          child: Text("hdjkfhkdjfhdkjfhdkjfhdkjfhkjdhfkjdhf"),
                        onTap: () {
                          showModalBottomSheet<void>(
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    topLeft: Radius.circular(20),
                                  )),
                              context: context,
                              builder: (BuildContext buildContext) {
                                return MyBottomSheet(
                                  selectOrder: (order) {
                                    context.read<AppBloc>().add(
                                      SelectOrder(order: order)
                                    );
                                  },
                                );
                              }
                          );
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
}
