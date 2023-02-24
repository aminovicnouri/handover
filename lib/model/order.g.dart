// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 1;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      id: fields[0] as int?,
      name: fields[1] as String,
      address: fields[2] as String,
      status: fields[3] as OrderStatus,
      pickupLatitude: fields[4] as double,
      pickupLongitude: fields[5] as double,
      deliveryLatitude: fields[6] as double,
      deliveryLongitude: fields[7] as double,
      rating: fields[8] as int?,
      price: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.pickupLatitude)
      ..writeByte(5)
      ..write(obj.pickupLongitude)
      ..writeByte(6)
      ..write(obj.deliveryLatitude)
      ..writeByte(7)
      ..write(obj.deliveryLongitude)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 2;

  @override
  OrderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatus.idle;
      case 1:
        return OrderStatus.runningForPickUp;
      case 2:
        return OrderStatus.picked;
      case 3:
        return OrderStatus.outForDelivery;
      case 4:
        return OrderStatus.nearDestination;
      case 5:
        return OrderStatus.delivered;
      default:
        return OrderStatus.idle;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    switch (obj) {
      case OrderStatus.idle:
        writer.writeByte(0);
        break;
      case OrderStatus.runningForPickUp:
        writer.writeByte(1);
        break;
      case OrderStatus.picked:
        writer.writeByte(2);
        break;
      case OrderStatus.outForDelivery:
        writer.writeByte(3);
        break;
      case OrderStatus.nearDestination:
        writer.writeByte(4);
        break;
      case OrderStatus.delivered:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
