import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:handover/model/order.dart';
import 'package:handover/services/geofence_service_manager.dart';
import 'package:meta/meta.dart';
import 'package:timelines/timelines.dart';

import '../repositories/order_repository.dart';

part 'bottom_sheet_event.dart';

part 'bottom_sheet_state.dart';

class BottomSheetBloc extends Bloc<BottomSheetEvent, BottomSheetState> {
  final OrderRepository _orderRepository;

  BottomSheetBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const BottomSheetListState(allOrders: [])) {

    on<Initialize>((event, emit) async {
      await _orderRepository.init();
      final list = await _orderRepository.getOrders();
      final running =
          list.where((element) =>  element.status != OrderStatus.idle && element.status != OrderStatus.delivered);
      if (running.isEmpty) {
        emit(BottomSheetListState(allOrders: list));
      } else {
        event.select(running.first);
        emit(BottomSheetOrderSelectedState(currentOrder: running.first));
      }
    });

    on<AddOrder>((event, emit) async {
      await _orderRepository.insertOrder(event.order);
      final list = await _orderRepository.getOrders();
      emit(BottomSheetListState(allOrders: list));
    });

    on<UpdateOrderEvent>((event, emit) async {
      final order = event.order;
      if(event.canBePickedOrDelivered) {
        if ((state as BottomSheetOrderSelectedState).currentOrder.status ==
            OrderStatus.runningForPickUp) {
          order.status = OrderStatus.picked;
        } else {
          order.status = OrderStatus.delivered;
        }
      }
      emit(BottomSheetOrderSelectedState(currentOrder: order, canBePickedOrDelivered: false));
      if(event.updateOrder != null) {
        event.updateOrder!(order);
      }
    });

    on<SelectOrderBottomSheetEvent>((event, emit) async {
      event.select(event.order);
      emit(BottomSheetOrderSelectedState(
        currentOrder: event.order,
      ));
    });

    on<AskForUpdateEvent>((event, emit) async {
      final currentState = state as BottomSheetOrderSelectedState;
      emit(BottomSheetOrderSelectedState(
        currentOrder: currentState.currentOrder,
        canBePickedOrDelivered: event.canBePickedOrDelivered,
      ));
    });
  }
}
