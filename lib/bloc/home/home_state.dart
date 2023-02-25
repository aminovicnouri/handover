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


}

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  locationServiceDisabled,
}
