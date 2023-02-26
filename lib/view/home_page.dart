import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:handover/bloc/bottomSheet/bottom_sheet_bloc.dart';
import 'package:handover/utils/constants.dart';
import 'package:handover/view/my_button.dart';

import '../bloc/home/home_bloc.dart';
import '../bloc/map/map_bloc.dart';
import '../repositories/order_repository_Impl.dart';
import '../services/geofence_service_manager.dart';
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
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            MapScreen(mapBloc: context.read<MapBloc>()),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: MyButton(
                                height: 45.h,
                                width: MediaQuery.of(context).size.width * .7,
                                backgroundColor: primaryColor,
                                text: 'Check Order',
                                onTap: () {
                                  _showMyBottomSheet(context);
                                },
                                icon: Icons.delivery_dining,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  );

                  switch (appState.permissionState) {
                    case LocationPermissionState.granted:

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
        barrierColor: Colors.transparent,
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
