part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {
  const HomeEvent();
}

@immutable
class StartLocationService implements HomeEvent {
  const StartLocationService();
}

@immutable
class StopLocationService implements HomeEvent {
  const StopLocationService();
}

@immutable
class CheckPermissions implements HomeEvent {
  const CheckPermissions();
}

@immutable
class ChangeOrderStatus implements HomeEvent {
  final OrderStatus status;

  const ChangeOrderStatus({
    required this.status,
  });
}

@immutable
class AskForStatusChange implements HomeEvent {
  final bool canBePickedOrDelivered;

  const AskForStatusChange({
    required this.canBePickedOrDelivered,
  });
}

@immutable
class RequestPermissions implements HomeEvent {
  const RequestPermissions();
}

@immutable
class SelectOrder implements HomeEvent {
  final Order? order;

  const SelectOrder({required this.order});
}

@immutable
class AddOrder implements HomeEvent {
  final Order order;

  const AddOrder({required this.order});
}

@immutable
class ChangeOrderStatusEvent implements HomeEvent {
  final OrderStatus orderStatus;

  const ChangeOrderStatusEvent({required this.orderStatus});
}

@immutable
class InitialState implements HomeEvent {
  const InitialState();
}

@immutable
class ShowBottomSheetEvent implements HomeEvent {
  final bool show;

  const ShowBottomSheetEvent({
    required this.show,
  });
}
