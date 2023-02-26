part of 'add_order_bloc.dart';

@immutable
abstract class AddOrderState {}

class AddOrderInitial extends AddOrderState {
  final bool missingFields;

  AddOrderInitial({this.missingFields = false});
}

class OrderAdded extends AddOrderState {}

