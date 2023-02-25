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
      final order = event.order;
      if (order.status == OrderStatus.idle) {
        order.status = OrderStatus.runningForPickUp;
        await _orderRepository.updateOrder(order);
      }
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

    on<ChangeOrderStatus>((event, emit) async {
      final order = state.currentOrder!;
      order.status = event.status;
      if(event.status != OrderStatus.nearDestination) {
        await _orderRepository.updateOrder(order);
      }
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
      final running = list.where((element) =>
          element.status != OrderStatus.idle &&
          element.status != OrderStatus.delivered);
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

      if (state.currentOrder?.status != OrderStatus.idle) {
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

      if (geofence.id.contains("origin")) {
        if (state.currentOrder?.status == OrderStatus.runningForPickUp && geofence.radius[0].status == GeofenceStatus.ENTER) {
          add(const ChangeOrderStatus(status: OrderStatus.picked));
        } else if (state.currentOrder?.status == OrderStatus.picked && geofence.radius[0].status == GeofenceStatus.EXIT) {
          add(const ChangeOrderStatus(status: OrderStatus.outForDelivery));
        }
      } else if (geofence.id.contains("destination")) {
        if (state.currentOrder?.status == OrderStatus.nearDestination && geofence.radius[0].status == GeofenceStatus.ENTER) {
          add(const ChangeOrderStatus(status: OrderStatus.delivered));
          _geofenceSubscription?.cancel();
        } else if (state.currentOrder?.status == OrderStatus.outForDelivery && geofence.radius[1].status == GeofenceStatus.ENTER) {
          add(const ChangeOrderStatus(status: OrderStatus.nearDestination));
        }
      }
    });
  }
}
