part of 'bottom_sheet_bloc.dart';

@immutable
abstract class BottomSheetEvent {}

class Initialize extends BottomSheetEvent{
  final Function(Order order) select;
  Initialize({required this.select});
}
class AddOrder extends BottomSheetEvent{
  final Order order;
  AddOrder({required this.order});
}

class UpdateOrderEvent extends BottomSheetEvent{
  final Order order;
  UpdateOrderEvent({required this.order});
}

class SelectOrderBottomSheetEvent extends BottomSheetEvent{
  final Order order;
  final Function(Order order) select;

  SelectOrderBottomSheetEvent({required this.order, required this.select});
}
