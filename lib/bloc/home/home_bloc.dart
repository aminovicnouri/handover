import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:handover/bloc/permissions.dart';
import 'package:handover/model/order.dart';
import 'package:handover/services/geofence_service_manager.dart';

import '../../notifications/local_notification_service.dart';
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
      emit(
        HomeState(
          allOrders: state.allOrders,
          currentOrder: state.currentOrder,
          serviceIsRunning: state.serviceIsRunning,
          permissionState: status,
          showBottomSheet: state.showBottomSheet,
          canBePickedOrDelivered: state.canBePickedOrDelivered,
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
        HomeState(
            allOrders: state.allOrders,
            currentOrder: order,
            serviceIsRunning: state.serviceIsRunning,
            permissionState: state.permissionState,
            showBottomSheet: state.showBottomSheet,
            canBePickedOrDelivered: state.canBePickedOrDelivered
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
        HomeState(
          allOrders: state.allOrders,
          currentOrder: order,
          serviceIsRunning: state.serviceIsRunning,
          permissionState: state.permissionState,
          showBottomSheet: state.showBottomSheet,
          canBePickedOrDelivered: false,
        ),
      );
    });

    on<AskForStatusChange>((event, emit) async {
      emit(
        HomeState(
          allOrders: state.allOrders,
          currentOrder: state.currentOrder,
          serviceIsRunning: state.serviceIsRunning,
          permissionState: state.permissionState,
          showBottomSheet: state.showBottomSheet,
          canBePickedOrDelivered: event.canBePickedOrDelivered,
        ),
      );
    });

    on<AddOrder>((event, emit) async {
      await _orderRepository.insertOrder(event.order);
      final list = await _orderRepository.getOrders();
      emit(
        HomeState(
            allOrders: list,
            currentOrder: state.currentOrder,
            serviceIsRunning: state.serviceIsRunning,
            permissionState: state.permissionState,
            showBottomSheet: state.showBottomSheet,
            canBePickedOrDelivered: state.canBePickedOrDelivered
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
        HomeState(
            allOrders: list,
            currentOrder: current,
            serviceIsRunning: state.serviceIsRunning,
            permissionState: state.permissionState,
            showBottomSheet: state.showBottomSheet,
            canBePickedOrDelivered: state.canBePickedOrDelivered
        ),
      );

      if (state.currentOrder?.status != OrderStatus.idle) {
        _listenToLocationChanges();
      }
    });
    on<ShowBottomSheetEvent>((event, emit) async {
      emit(
        HomeState(
            allOrders: state.allOrders,
            currentOrder: state.currentOrder,
            serviceIsRunning: state.serviceIsRunning,
            permissionState: state.permissionState,
            showBottomSheet: event.show,
            canBePickedOrDelivered: state.canBePickedOrDelivered
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
    _geofenceSubscription = GeofenceServiceManager.instance()
        .geofenceStreamController
        .stream
        .listen((geofence) {
      LocalNotificationService.showNotificationWithPayload(id: 111, title: geofence.id, body: geofence.status.name, payload: "");

      add(const ShowBottomSheetEvent(show: true));
      if (geofence.id.contains("origin")) {
        if (state.currentOrder?.status == OrderStatus.runningForPickUp) {
          if(geofence.radius[0].status == GeofenceStatus.ENTER) {
            add(const AskForStatusChange(canBePickedOrDelivered: true));
          } else  if(geofence.radius[0].status == GeofenceStatus.EXIT) {
            add(const AskForStatusChange(canBePickedOrDelivered: false));
          }
        } else if (state.currentOrder?.status == OrderStatus.picked && geofence.radius[0].status == GeofenceStatus.EXIT) {
          add(const ChangeOrderStatus(status: OrderStatus.outForDelivery));
        }
      } else if (geofence.id.contains("destination")) {
        if (state.currentOrder?.status == OrderStatus.nearDestination && geofence.radius[0].status == GeofenceStatus.ENTER) {
          add(const AskForStatusChange(canBePickedOrDelivered: true));
          _geofenceSubscription?.cancel();
        } else if (state.currentOrder?.status == OrderStatus.outForDelivery) {
          if(geofence.radius[1].status == GeofenceStatus.ENTER) {
            add(const ChangeOrderStatus(status: OrderStatus.nearDestination));
          } else {
            add(const ChangeOrderStatus(status: OrderStatus.outForDelivery));
          }
        }
      }
    });
  }
}
