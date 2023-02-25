part of 'bottom_sheet_bloc.dart';

class BottomSheetState extends Equatable {
  const BottomSheetState();

  @override
  List<Object> get props => [];
}

class BottomSheetListState extends BottomSheetState {
  final List<Order> allOrders;

  const BottomSheetListState({
    required this.allOrders,
  });

  @override
  List<Object> get props => [allOrders];
}

class BottomSheetOrderSelectedState extends BottomSheetState {
  final Order currentOrder;
  final bool canBePickedOrDelivered;

  const BottomSheetOrderSelectedState({
    required this.currentOrder,
    this.canBePickedOrDelivered = false,
  });

  @override
  List<Object> get props => [currentOrder, canBePickedOrDelivered];
}
