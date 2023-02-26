import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handover/model/order.dart';

import '../../repositories/order_repository.dart';

part 'bottom_sheet_event.dart';

part 'bottom_sheet_state.dart';

class BottomSheetBloc extends Bloc<BottomSheetEvent, BottomSheetState> {
  final OrderRepository _orderRepository;

  BottomSheetBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(BottomSheetState.empty()) {
    on<Initialize>((event, emit) async {
      await _orderRepository.init();
      final list = await _orderRepository.getOrders();
      final running = list.where((element) =>
          element.status != OrderStatus.idle &&
          element.status != OrderStatus.submitted);
      if (running.isEmpty) {
        emit(BottomSheetState(
            allOrders: list,
            currentOrder: null,
            canBePickedOrDelivered: false));
      } else {
        event.select(running.first);
        emit(BottomSheetState(
            allOrders: list,
            currentOrder: running.first,
            canBePickedOrDelivered: false));
      }
    });

    on<UpdateOrderEvent>((event, emit) async {
      Order order = event.order;
      if (event.canBePickedOrDelivered) {
        if (state.currentOrder!.status == OrderStatus.runningForPickUp) {
          order.status = OrderStatus.picked;
          order.pickUpTime = DateTime.now().microsecondsSinceEpoch / 1000;
        } else {
          order.status = OrderStatus.delivered;
          order.deliveryTime = DateTime.now().microsecondsSinceEpoch / 1000;
        }
      }
      event.updateOrder!(order);
      emit(state.copyWith(currentOrder: order));
    });

    on<UpdateOrderStatusEvent>((event, emit) {
      emit(state.copyWith(
          canBePickedOrDelivered: false, currentOrder: event.order));
    });

    on<SubmitOrderEvent>((event, emit) async {
      Order order = event.order;
      order.status = OrderStatus.submitted;
      print("hhhhhhhh ${order.status}");
      await _orderRepository.updateOrder(order);
      final orders = await _orderRepository.getOrders();
      event.clear();
      emit(
        BottomSheetState(
          allOrders: orders,
          currentOrder: null,
          canBePickedOrDelivered: false,
        ),
      );
    });

    on<UpdateOrderRatingEvent>((event, emit) {
      final order = state.currentOrder;
      order!.rating = event.rating;
      emit(state.copyWith(currentOrder: order));
    });

    on<SelectOrderBottomSheetEvent>((event, emit) async {
      event.select(event.order);
      emit(state.copyWith(currentOrder: event.order));
    });

    on<AskForUpdateEvent>((event, emit) async {
      emit(state.copyWith(
        canBePickedOrDelivered: event.canBePickedOrDelivered,
      ));
    });
  }
}
