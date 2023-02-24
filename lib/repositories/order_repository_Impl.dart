import 'package:handover/model/order.dart';
import 'package:hive/hive.dart';
import 'order_repository.dart';


class OrderRepositoryImpl extends OrderRepository{
  static Box? orders ;
  static Box? status ;
  static bool isInitialised = false;

  @override
  Future<void> deleteOrder(Order order) async {
    orders?.delete(order);
  }

  @override
  Future<List<Order>> getOrders() async{
    List<Order> items = [] ;
    if( orders != null && orders!.values.isNotEmpty){
      items.addAll(orders!.values.map((e) => e as Order));
    }
    return items;
  }

  @override
  Future<void> init() async{
    if(!isInitialised) {
      if(!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter<Order>(OrderAdapter());
      }
      if(!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter<OrderStatus>(OrderStatusAdapter());
      }

      orders = await Hive.openBox<Order>('orders');
      status = await Hive.openBox<OrderStatus>('status');
      isInitialised = true;
    }
  }

  @override
  Future<void> insertOrder(Order order) async {
    orders?.add(order);
  }

  @override
  Future<void> updateOrder(Order order) async{
    order.save();
  }
}
