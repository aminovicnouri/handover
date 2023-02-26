part of 'home_bloc.dart';

@immutable
class HomeState {
  final Order? currentOrder;
  final List<Order> allOrders;
  final bool showBottomSheet;
  final bool canBePickedOrDelivered;

  const HomeState(
      {required this.currentOrder,
      required this.allOrders,
      required this.showBottomSheet,
      required this.canBePickedOrDelivered});

  HomeState.empty()
      : currentOrder = null,
        allOrders = [],
        showBottomSheet = false,
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
