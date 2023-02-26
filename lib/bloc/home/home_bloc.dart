import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:handover/bloc/permissions.dart';
import 'package:handover/model/order.dart';
import 'package:handover/services/geofence_service_manager.dart';

import '../../repositories/order_repository.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  StreamSubscription? _geofenceSubscription;
  final OrderRepository _orderRepository;

  HomeBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(HomeState.empty()) {
    _orderRepository.init();

    on<CheckPermissions>((event, emit) async {
      final status = await checkPermissions();
      emit(state.copyWith(permissionState: status));
    });

    on<SelectOrder>((event, emit) async {
      if (event.order != null) {
        if (event.order!.status == OrderStatus.idle) {
          event.order!.status = OrderStatus.runningForPickUp;
          await _orderRepository.updateOrder(event.order!);
        }
        emit(state.copyWith(currentOrder: event.order));
        _syncWithService();
      } else {
        final orders = await _orderRepository.getOrders();
        emit(
          HomeState(
              currentOrder: null,
              allOrders: orders,
              serviceIsRunning: state.serviceIsRunning,
              showBottomSheet: state.showBottomSheet,
              canBePickedOrDelivered: false),
        );
      }
    });

    on<ChangeOrderStatus>((event, emit) async {
      final order = state.currentOrder!;
      order.status = event.status;
      if (event.status != OrderStatus.nearDestination) {
        await _orderRepository.updateOrder(order);
      }
      emit(state.copyWith(currentOrder: order, canBePickedOrDelivered: false));
      if (state.currentOrder?.status == OrderStatus.outForDelivery &&
          (GeofenceServiceManager.instance().operationGeofence?.id ?? "")
              .contains("origin")) {
        _syncWithService();
      }
    });

    on<AskForStatusChange>((event, emit) async {
      emit(
        state.copyWith(canBePickedOrDelivered: event.canBePickedOrDelivered),
      );
    });

    on<AddOrder>((event, emit) async {
      await _orderRepository.insertOrder(event.order);
      final list = await _orderRepository.getOrders();
      emit(
        state.copyWith(allOrders: list),
      );
    });
    on<InitialState>((event, emit) async {
      await _orderRepository.init();
      final list = await _orderRepository.getOrders();
      final running = list.where((element) =>
          element.status != OrderStatus.idle &&
          element.status != OrderStatus.submitted);
      final current = running.isEmpty ? null : running.first;
      emit(
        state.copyWith(allOrders: list, currentOrder: current),
      );
      GeofenceServiceManager.instance().start();
      _syncWithService();
      _listenToLocationChanges();
    });
    on<ShowBottomSheetEvent>((event, emit) async {
      emit(state.copyWith(showBottomSheet: event.show));
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
    _geofenceSubscription?.cancel();
    _geofenceSubscription =
        GeofenceServiceManager.instance().controller.stream.listen((geofence) {
      _handleGeofence(geofence);
    });
  }

  void _handleGeofence(Geofence geofence) {
    final radius0 = geofence.radius[0];
    final radius1 = geofence.radius[1];
    final currentOrderStatus = state.currentOrder?.status;

    switch (geofence.id) {
      case "origin":
        if (currentOrderStatus == OrderStatus.runningForPickUp) {
          if (radius0.status == GeofenceStatus.ENTER) {
            add(const AskForStatusChange(canBePickedOrDelivered: true));
          } else if (radius0.status == GeofenceStatus.EXIT) {
            add(const AskForStatusChange(canBePickedOrDelivered: false));
          }
        } else if (currentOrderStatus == OrderStatus.picked &&
            radius0.status == GeofenceStatus.EXIT) {
          add(const ChangeOrderStatus(status: OrderStatus.outForDelivery));
        }
        break;

      case "destination":
        if (currentOrderStatus == OrderStatus.nearDestination) {
          if (radius1.status == GeofenceStatus.EXIT) {
            add(const ChangeOrderStatus(status: OrderStatus.outForDelivery));
          }
          if (radius0.status == GeofenceStatus.ENTER) {
            add(const AskForStatusChange(canBePickedOrDelivered: true));
          }
        } else if (currentOrderStatus == OrderStatus.outForDelivery &&
            radius1.status == GeofenceStatus.ENTER) {
          add(const ChangeOrderStatus(status: OrderStatus.nearDestination));
        }
        break;

      default:
        break;
    }
  }

  void _syncWithService() {
    List<Geofence> geofenceList = [];
    final order = state.currentOrder;
    if (order != null) {
      switch (order.status) {
        case OrderStatus.idle:
        case OrderStatus.runningForPickUp:
        case OrderStatus.picked:
          geofenceList.add(Geofence(
            id: "origin",
            latitude: order.pickupLatitude,
            longitude: order.pickupLongitude,
            radius: [
              GeofenceRadius(id: '${order.name}_origin_100m', length: 500),
              GeofenceRadius(id: '${order.name}_origin_1000m', length: 5000),
            ],
          ));
          break;

        case OrderStatus.outForDelivery:
        case OrderStatus.nearDestination:
          geofenceList.add(Geofence(
            id: "destination",
            latitude: order.deliveryLatitude,
            longitude: order.deliveryLongitude,
            radius: [
              GeofenceRadius(id: '${order.name}_destination_100m', length: 500),
              GeofenceRadius(
                  id: '${order.name}_destination_1000m', length: 5000),
            ],
          ));
          break;

        default:
          break;
      }
    }
    GeofenceServiceManager.instance().updateGeofences(geofenceList);
  }
}
