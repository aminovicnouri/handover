part of 'add_order_bloc.dart';

@immutable
abstract class AddOrderEvent {}

class AddMoreOrderEvent extends AddOrderEvent {}

class AddOrderToDatabaseEvent extends AddOrderEvent {
  final String name;
  final String address;
  final String price;
  final GeoPoint? pickup;
  final GeoPoint? delivery;

  AddOrderToDatabaseEvent({
    required this.name,
    required this.address,
    required this.price,
    required this.pickup,
    required this.delivery,
  });
}
