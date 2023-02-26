import 'package:handover/model/order.dart';

abstract class OrderRepository {
  Future<void> init();

  Future<List<Order>> getOrders();

  Future<void> insertOrder(Order order);

  Future<void> updateOrder(Order order);

  Future<void> deleteOrder(Order order);
}
