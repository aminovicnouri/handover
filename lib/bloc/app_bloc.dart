import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handover/bloc/permissions.dart';
import 'package:handover/model/order.dart';
import 'package:handover/services/geofence_service_manager.dart';

import '../repositories/order_repository.dart';
import 'app_state.dart';
import 'bloc_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  StreamSubscription? _geolocationSubscription;
  final OrderRepository _orderRepository;

  AppBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(AppState.empty()) {
    on<StartLocationService>((event, emit) async {
      _geolocationSubscription?.cancel();
      _listenToLocationChanges();
      emit(
        AppState(
            allOrders: state.allOrders,
            currentOrder: state.currentOrder,
            serviceIsRunning: true,
            permissionState: state.permissionState),
      );
    });
    on<StopLocationService>((event, emit) async {
      _geolocationSubscription?.cancel();
      emit(
        AppState(
            allOrders: state.allOrders,
            currentOrder: null,
            serviceIsRunning: false,
            permissionState: state.permissionState),
      );
    });

    on<LocationUpdated>((event, emit) {});

    on<CheckPermissions>((event, emit) async {
      final status = await checkPermissions();
      emit(
        AppState(
            allOrders: state.allOrders,
            currentOrder: state.currentOrder,
            serviceIsRunning: state.serviceIsRunning,
            permissionState: status),
      );
    });

    on<SelectOrder>((event, emit) async {
      emit(
        AppState(
            allOrders: state.allOrders,
            currentOrder: event.order,
            serviceIsRunning: state.serviceIsRunning,
            permissionState: state.permissionState),
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
            permissionState: state.permissionState
        ),
      );
    });

    on<InitialState>((event, emit) async {
      final list = await _orderRepository.getOrders();
      final order = list.where((element) => element.status == OrderStatus.running).first;
      emit(
        AppState(
            allOrders: list,
            currentOrder: order,
            serviceIsRunning: state.serviceIsRunning,
            permissionState: state.permissionState
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
    _geolocationSubscription?.cancel();
    return super.close();
  }

  void _listenToLocationChanges() {
    GeofenceServiceManager.instance().start();
  }
}
