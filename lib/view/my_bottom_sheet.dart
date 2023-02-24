import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handover/bottomSheet/bottom_sheet_bloc.dart';
import 'package:handover/model/order.dart';
import 'package:handover/repositories/order_repository_Impl.dart';

class MyBottomSheet extends StatelessWidget {
  const MyBottomSheet({
    required this.selectOrder,
    Key? key,
  }) : super(key: key);

  final Function(Order order) selectOrder;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
        create: (_) => OrderRepositoryImpl(),
        child: BlocProvider(
          create: (context) => BottomSheetBloc(
              orderRepository: context.read<OrderRepositoryImpl>())
            ..add(Initialize()),
          child: BlocBuilder<BottomSheetBloc, BottomSheetState>(
            builder: (context, appState) {
              return Stack(
                children: [
                  Container(
                      height: 400,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 40),
                      decoration: const BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          )),
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: appState.allOrders.length,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onTap: () {
                                    context.read<BottomSheetBloc>().add(SelectOrder(order: appState.allOrders[index], select: selectOrder));
                                  },
                                  child: Text(
                                    appState.allOrders[index].name,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<BottomSheetBloc>().add(
                                      AddOrder(
                                          order: Order(
                                              id: 5,
                                              name: "order test",
                                              address: "dfdfdf",
                                              status: OrderStatus.idle,
                                              pickupLatitude: 25.089119,
                                              pickupLongitude: 55.146406,
                                              deliveryLatitude: 25.326601,
                                              deliveryLongitude: 55.405458,
                                              rating: 4,
                                              price: 55)),
                                    );
                              },
                              child: const Text(
                                "Add order",
                              ),
                            )
                          ],
                        ),
                      )),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
