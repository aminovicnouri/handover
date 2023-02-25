part of 'bottom_sheet_bloc.dart';

class BottomSheetEvent extends Equatable {
  const BottomSheetEvent();

  @override
  List<Object> get props => [];
}

class Initialize extends BottomSheetEvent {
  final Function(Order order) select;

  const Initialize({required this.select});

  @override
  List<Object> get props => [select];
}

class AddOrder extends BottomSheetEvent {
  final Order order;

  const AddOrder({required this.order});

  @override
  List<Object> get props => [order];
}

class UpdateOrderEvent extends BottomSheetEvent {
  final Order order;

  const UpdateOrderEvent({required this.order});

  @override
  List<Object> get props => [order];
}

class SelectOrderBottomSheetEvent extends BottomSheetEvent {
  final Order order;
  final Function(Order order) select;

  const SelectOrderBottomSheetEvent(
      {required this.order, required this.select});

  @override
  List<Object> get props => [order, select];
}
