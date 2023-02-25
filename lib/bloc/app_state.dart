import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../model/order.dart';

@immutable
class AppState {
  final Order? currentOrder;
  final List<Order> allOrders;
  final bool serviceIsRunning;
  final LocationPermissionState? permissionState;
  final bool showBottomSheet;
  final bool canBePickedOrDelivered;

  const AppState(
      {required this.currentOrder,
      required this.allOrders,
      required this.serviceIsRunning,
      required this.showBottomSheet,
      this.permissionState,
      required this.canBePickedOrDelivered});

  AppState.empty()
      : currentOrder = null,
        allOrders = [],
        serviceIsRunning = false,
        showBottomSheet = false,
        permissionState = null,
        canBePickedOrDelivered = false;


}

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  locationServiceDisabled,
}
