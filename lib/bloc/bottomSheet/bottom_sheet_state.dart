part of 'bottom_sheet_bloc.dart';

@immutable
class BottomSheetState {
  final List<Order> allOrders;
  final Order? currentOrder;
  final bool canBePickedOrDelivered;

  const BottomSheetState({
    required this.allOrders,
    required this.currentOrder,
    required this.canBePickedOrDelivered,
  });

  BottomSheetState copyWith({
    List<Order>? allOrders,
    Order? currentOrder,
    bool? canBePickedOrDelivered,
  }) {
    return BottomSheetState(
      allOrders: allOrders ?? this.allOrders,
      currentOrder: currentOrder ?? this.currentOrder,
      canBePickedOrDelivered:
          canBePickedOrDelivered ?? this.canBePickedOrDelivered,
    );
  }

  static BottomSheetState empty() {
    return (const BottomSheetState(
        allOrders: [], currentOrder: null, canBePickedOrDelivered: false));
  }
}
