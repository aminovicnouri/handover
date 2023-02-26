import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:go_router/go_router.dart';
import 'package:handover/bloc/bottomSheet/bottom_sheet_bloc.dart';
import 'package:handover/model/order.dart';

import '../bloc/home/home_bloc.dart';
import '../bloc/map/map_bloc.dart';
import '../repositories/order_repository_Impl.dart';
import '../services/geofence_service_manager.dart';
import '../utils/constants.dart';
import 'map_screen.dart';
import 'orders_bottom_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillStartForegroundTask(
        onWillStart: () async {
          // You can add a foreground task start condition.
          return GeofenceServiceManager.instance().isRunningService();
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription:
              'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.HIGH,
          priority: NotificationPriority.HIGH,
          isSticky: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        foregroundTaskOptions: const ForegroundTaskOptions(),
        child: RepositoryProvider(
          create: (_) => OrderRepositoryImpl(),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<HomeBloc>(
                  create: (context) => HomeBloc(
                      orderRepository: context.read<OrderRepositoryImpl>())
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
                backgroundColor: primaryColor,
                actions: [
                  IconButton(
                      onPressed: () {
                        context.go('/addOrder');
                      },
                      icon: const Icon(Icons.add))
                ],
              ),
              body: BlocConsumer<HomeBloc, HomeState>(
                listenWhen: (previousState, currentState) {
                  previousState.currentOrder?.status !=
                      currentState.currentOrder?.status;
                  return true;
                },
                listener: (BuildContext context, HomeState state) {
                  final mapBloc = context.read<MapBloc>();
                  final bottomSheetBloc = context.read<BottomSheetBloc>();

                  if (state.showBottomSheet && !isBottomSheetVisible(context)) {
                    _showMyBottomSheet(context);
                  }

                  if (state.currentOrder != null &&
                      mapBloc.state.markers.isEmpty) {
                    mapBloc.add(AddMarkersEvent(order: state.currentOrder));
                  }

                  if (state.canBePickedOrDelivered) {
                    bottomSheetBloc.add(AskForUpdateEvent(
                        canBePickedOrDelivered: state.canBePickedOrDelivered));
                  } else if (state.currentOrder != null) {
                    bottomSheetBloc.add(
                        UpdateOrderStatusEvent(order: state.currentOrder!));
                  }
                },
                builder: (context, appState) {
                  switch (appState.permissionState) {
                    case LocationPermissionState.granted:
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<HomeBloc>().add(
                                  const ChangeOrderStatus(
                                      status: OrderStatus.delivered));
                            },
                            child: Text(
                                'selected order: ${appState.currentOrder?.name ?? "null"}'),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                MapScreen(mapBloc: context.read<MapBloc>()),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: FloatingActionButton(
                                        onPressed: () =>
                                            _showMyBottomSheet(context),
                                        elevation: 10,
                                        backgroundColor: primaryColor,
                                        child: const Icon(
                                          Icons.delivery_dining,
                                          color: Colors.white,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    case LocationPermissionState.denied:
                      return Center(
                        child: TextButton(
                          onPressed: () {
                            context.read<HomeBloc>().add(
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
                            context.read<HomeBloc>().add(
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
        ));
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
              context.read<HomeBloc>().add(SelectOrder(order: order));
              context.read<MapBloc>().add(AddMarkersEvent(order: order));
            },
            updateOrder: (order) {
              context
                  .read<HomeBloc>()
                  .add(ChangeOrderStatus(status: order.status));
            },
            clearSelection: () {
              print("hhhhhh");
              context.read<HomeBloc>().add(const SelectOrder(order: null));

              context.read<MapBloc>().add(AddMarkersEvent(order: null));
            },
          );
        });
  }

  bool isBottomSheetVisible(BuildContext context) {
    final navigator = Navigator.of(context);
    return navigator.canPop();
  }
}
