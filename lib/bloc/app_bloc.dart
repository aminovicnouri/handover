import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:handover/bloc/permissions.dart';
import 'package:handover/model/order.dart';
import 'package:handover/services/geofence_service_manager.dart';

import '../repositories/order_repository.dart';
import 'app_state.dart';
import 'bloc_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  StreamSubscription? _geofenceSubscription;
  final OrderRepository _orderRepository;

  AppBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(AppState.empty()) {
    _orderRepository.init();
    on<CheckPermissions>((event, emit) async {
      final status = await checkPermissions();
      emit(
        AppState(
          allOrders: state.allOrders,
          currentOrder: state.currentOrder,
          serviceIsRunning: state.serviceIsRunning,
          permissionState: status,
          showBottomSheet: state.showBottomSheet,
        ),
      );
    });

    on<SelectOrder>((event, emit) async {
      Order order = event.order;
      order.status = OrderStatus.runningForPickUp;
      await _orderRepository.updateOrder(order);
      emit(
        AppState(
          allOrders: state.allOrders,
          currentOrder: order,
          serviceIsRunning: state.serviceIsRunning,
          permissionState: state.permissionState,
          showBottomSheet: state.showBottomSheet,
        ),
      );
    });

    on<AddOrder>((event, emit) async {
      await _orderRepository.insertOrder(event.order);
      final list = await _orderRepository.getOrders();
      emit(
        AppState(
          allOrders: list,
          currentOrder: state.currentOrder,
          serviceIsRunning: state.serviceIsRunning,
          permissionState: state.permissionState,
          showBottomSheet: state.showBottomSheet,
        ),
      );
    });
    on<InitialState>((event, emit) async {
      await _orderRepository.init();
      final list = await _orderRepository.getOrders();
      final running =
          list.where((element) => element.status != OrderStatus.idle && element.status != OrderStatus.delivered);
      final current = running.isEmpty ? null : running.first;
        emit(
          AppState(
            allOrders: list,
            currentOrder: current,
            serviceIsRunning: state.serviceIsRunning,
            permissionState: state.permissionState,
            showBottomSheet: state.showBottomSheet,
          ),
        );

        if(state.currentOrder?.status != OrderStatus.idle){
          _listenToLocationChanges();
        }
    });
    on<ShowBottomSheetEvent>((event, emit) async {
      emit(
        AppState(
          allOrders: state.allOrders,
          currentOrder: state.currentOrder,
          serviceIsRunning: state.serviceIsRunning,
          permissionState: state.permissionState,
          showBottomSheet: event.show,
        ),
      );
    });

    on<RequestPermissions>((event, emit) async {
      await requestPermissions();
      add(const CheckPermissions());
    });
  }

  @override
  Future<void> close() {
    _geofenceSubscription?.cancel();
    return super.close();
  }

  void _listenToLocationChanges() {
    print("hhhhhhhhhh listen");

    _geofenceSubscription = GeofenceServiceManager.instance()
       .geofenceStreamController
       .stream
       .listen((geofence) {
     add(const ShowBottomSheetEvent(show: true));
     // if(geofence.id.contains("origin") && state.currentOrder!.status == OrderStatus.idle) {
     //   // if(geofence.radius[0].status == GeofenceStatus.ENTER)
     // }
     // if (geofence.radius[0].status == GeofenceStatus.ENTER) {
     //   add(const ShowBottomSheetEvent(show: true));
     //   if (state.currentOrder?.status == OrderStatus.idle) {
     //     add(const ShowBottomSheetEvent(show: true));
     //     //confirmPickup();
     //   } else {
     //     //confirmDelivery();
     //   }
     // }
   });
  }
}
