import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handover/bottomSheet/bottom_sheet_bloc.dart';
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
          BlocProvider<BottomSheetBloc>(
              create: (context) => BottomSheetBloc(
                    orderRepository: context.read<OrderRepositoryImpl>(),
                  )),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Home Page'),
          ),
          body: BlocConsumer<AppBloc, AppState>(
            listenWhen: (previousState, currentState) {
              previousState.currentOrder?.status !=
                      currentState.currentOrder?.status;
              return true;
            },
            listener: (BuildContext context, AppState state) {
              final mapBloc = context.read<MapBloc>();
              final bottomSheetBloc = context.read<BottomSheetBloc>();

              if (state.showBottomSheet && !isBottomSheetVisible(context)) {
                _showMyBottomSheet(context);
              }
              if (mapBloc.state.markers.isEmpty) {
                mapBloc.add(AddMarkersEvent(order: state.currentOrder));
              }

              if (bottomSheetBloc.state is BottomSheetOrderSelectedState) {
                final bottomSheetState = bottomSheetBloc.state as BottomSheetOrderSelectedState;
                if (state.currentOrder?.status != bottomSheetState
                        .currentOrder
                        .status) {
                  bottomSheetBloc
                      .add(UpdateOrderEvent(order: state.currentOrder!));
                }

                if(state.canBePickedOrDelivered != bottomSheetState.canBePickedOrDelivered) {
                  bottomSheetBloc.add(AskForUpdateEvent(canBePickedOrDelivered: state.canBePickedOrDelivered));
                }
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
            bottomSheetBloc: context.read<BottomSheetBloc>(),
            selectOrder: (order) {
              context.read<AppBloc>().add(SelectOrder(order: order));
            },
            updateOrder: (order) {
              context.read<AppBloc>().add(ChangeOrderStatus(status: order.status));
            },
          );
        });
  }

  bool isBottomSheetVisible(BuildContext context) {
    final navigator = Navigator.of(context);
    return navigator.canPop();
  }
}
