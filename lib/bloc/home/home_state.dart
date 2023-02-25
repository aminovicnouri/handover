part of 'home_bloc.dart';

@immutable
class HomeState {
  final Order? currentOrder;
  final List<Order> allOrders;
  final bool serviceIsRunning;
  final LocationPermissionState? permissionState;
  final bool showBottomSheet;
  final bool canBePickedOrDelivered;

  const HomeState(
      {required this.currentOrder,
      required this.allOrders,
      required this.serviceIsRunning,
      required this.showBottomSheet,
      this.permissionState,
      required this.canBePickedOrDelivered});

  HomeState.empty()
      : currentOrder = null,
        allOrders = [],
        serviceIsRunning = false,
        showBottomSheet = false,
        permissionState = null,
        canBePickedOrDelivered = false;

  HomeState copyWith({
    Order? currentOrder,
    List<Order>? allOrders,
    bool? serviceIsRunning,
    LocationPermissionState? permissionState,
    bool? showBottomSheet,
    bool? canBePickedOrDelivered,
  }) {
    return HomeState(
      currentOrder: currentOrder ?? this.currentOrder,
      allOrders: allOrders ?? this.allOrders,
      serviceIsRunning: serviceIsRunning ?? this.serviceIsRunning,
      permissionState: permissionState ?? this.permissionState,
      showBottomSheet: showBottomSheet ?? this.showBottomSheet,
      canBePickedOrDelivered:
          canBePickedOrDelivered ?? this.canBePickedOrDelivered,
    );
  }
}

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  locationServiceDisabled,
}
