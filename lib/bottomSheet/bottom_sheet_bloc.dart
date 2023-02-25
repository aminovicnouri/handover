import 'package:bloc/bloc.dart';
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
        super(BottomSheetState.empty()) {

    on<Initialize>((event, emit) async {
      await _orderRepository.init();
      final list = await _orderRepository.getOrders();
      final running =
          list.where((element) =>  element.status != OrderStatus.idle && element.status != OrderStatus.delivered);
      if (running.isEmpty) {
        emit(BottomSheetState(allOrders: list, order: null));
      } else {
        event.select(running.first);
        emit(BottomSheetState(allOrders: list, order: running.first));
      }
    });

    on<AddOrder>((event, emit) async {
      await _orderRepository.insertOrder(event.order);
      final list = await _orderRepository.getOrders();
      emit(BottomSheetState(allOrders: list, order: state.order));
    });
    on<UpdateOrderEvent>((event, emit) async {
      emit(BottomSheetState(allOrders: state.allOrders, order: event.order));
    });


    on<SelectOrderBottomSheetEvent>((event, emit) async {
      event.select(event.order);
      emit(BottomSheetState(
        allOrders: state.allOrders,
        order: event.order,
      ));
    });
  }
}
