import 'package:flutter/foundation.dart' show immutable;

import '../model/order.dart';

@immutable
class AppState {
  final Order? currentOrder;
  final List<Order> allOrders;
  final bool serviceIsRunning;
  final LocationPermissionState? permissionState;
  final bool showBottomSheet;

  const AppState({
    required this.currentOrder,
    required this.allOrders,
    required this.serviceIsRunning,
    required this.showBottomSheet,
    this.permissionState,
  });

   AppState.empty()
      : currentOrder = null,
        allOrders = [],
        serviceIsRunning = false,
         showBottomSheet = false,
        permissionState = null;
}

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  locationServiceDisabled,
}
