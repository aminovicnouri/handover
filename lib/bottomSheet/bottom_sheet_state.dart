part of 'bottom_sheet_bloc.dart';

@immutable
class BottomSheetState {
  final List<Order> allOrders;
  final Order? order;

  const BottomSheetState({
    required this.allOrders,
    required this.order,
  });

  static BottomSheetState empty() {
    return const BottomSheetState(
      allOrders: [],
      order: null
    );
  }
}
