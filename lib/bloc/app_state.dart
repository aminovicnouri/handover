import 'package:flutter/foundation.dart' show immutable;

import '../model/order.dart';

@immutable
class AppState {
  final Order? currentOrder;
  final List<Order> allOrders;
  final bool serviceIsRunning;
  final LocationPermissionState? permissionState;

  const AppState({
    required this.currentOrder,
    required this.allOrders,
    required this.serviceIsRunning,
    this.permissionState,
  });

   AppState.empty()
      : currentOrder = null,
        allOrders = [],
        serviceIsRunning = false,
        permissionState = null;
}

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  locationServiceDisabled,
}
