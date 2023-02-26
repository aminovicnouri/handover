
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:handover/model/order.dart';

import '../../repositories/order_repository.dart';

part 'add_order_event.dart';

part 'add_order_state.dart';

class AddOrderBloc extends Bloc<AddOrderEvent, AddOrderState> {
  final OrderRepository _orderRepository;

  AddOrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(AddOrderInitial()) {
    on<AddOrderToDatabaseEvent>((event, emit) async {
      if (event.name.isEmpty ||
          event.address.isEmpty ||
          event.price.isEmpty ||
          event.pickup == null ||
          event.delivery == null) {
        emit(AddOrderInitial(missingFields: true));
      } else {
        _orderRepository.insertOrder(Order(
          id: 111,
          name: event.name,
          address: event.address,
          status: OrderStatus.idle,
          pickupLatitude: event.pickup!.latitude,
          pickupLongitude: event.pickup!.longitude,
          deliveryLatitude: event.delivery!.latitude,
          deliveryLongitude: event.delivery!.longitude,
          rating: 0,
          price: double.tryParse(event.price),
          pickUpTime: null,
          deliveryTime: null
        ));
        emit(OrderAdded());
      }
    });
    on<AddMoreOrderEvent>((event, emit) {
      emit(AddOrderInitial());
    });
  }
}
