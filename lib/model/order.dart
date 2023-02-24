import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:hive/hive.dart';

part 'order.g.dart';


@HiveType(typeId: 1)
class Order extends HiveObject {
  Order({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.rating,
    required this.price,
  });
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String name;


  @HiveField(2)
  final String address;

  @HiveField(3)
  OrderStatus status;

  @HiveField(4)
  final double pickupLatitude;

  @HiveField(5)
  final double pickupLongitude;

  @HiveField(6)
  final double deliveryLatitude;

  @HiveField(7)
  final double deliveryLongitude;

  @HiveField(8)
  final int? rating;

  @HiveField(9)
  final double? price;

  List<LatLng> getLatLngs() {
    return [LatLng(pickupLatitude, pickupLongitude), LatLng(deliveryLatitude, deliveryLongitude)];
  }

}

@HiveType(typeId: 2)
enum OrderStatus {

  @HiveField(0)
  idle("idle"),

  @HiveField(1)
  runningForPickUp("Running for pick up"),

  @HiveField(2)
  picked("Picked up delivery"),

  @HiveField(3)
  outForDelivery("Out for delivery"),

  @HiveField(4)
  nearDestination("Near delivery destination"),

  @HiveField(5)
  delivered("delivered");

  const OrderStatus(this.value);

  final String value;

  static OrderStatus getOrderStatus(String value) {
    return OrderStatus.values
        .firstWhere((element) => element.toString() == 'OrderStatus.$value');
  }
}



