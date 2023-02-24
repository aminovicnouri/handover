import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handover/bottomSheet/bottom_sheet_bloc.dart';
import 'package:handover/model/order.dart';
import 'package:handover/repositories/order_repository_Impl.dart';
import 'package:timelines/timelines.dart';

class OrdersBottomSheet extends StatelessWidget {
  const OrdersBottomSheet({
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
            ..add(Initialize(select: selectOrder)),
          child: BlocBuilder<BottomSheetBloc, BottomSheetState>(
            builder: (context, appState) {
              return SizedBox(
                height: appState.order == null ? 600 : 500,
                child: Stack(
                  children: [
                    Container(
                      alignment: appState.order == null ? Alignment.center : Alignment.centerLeft,
                      height: 600,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 60),
                      decoration: const BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          )),
                      child: appState.order == null
                          ? Column(
                              children: [
                                Container(
                                  height: 40,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(top: 40),
                                    itemCount: appState.allOrders.length,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () {
                                        context.read<BottomSheetBloc>().add(
                                            SelectOrder(
                                                order:
                                                    appState.allOrders[index],
                                                select: selectOrder));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  appState
                                                      .allOrders[index].name,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  appState
                                                      .allOrders[index].address,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            ElevatedButton(
                                              onPressed: () {},
                                              child: Text("check"),
                                            )
                                          ],
                                        ),
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
                            )
                          : Center(
                            child: Container(
                                // margin: const EdgeInsets.symmetric(
                                //     vertical: 50, horizontal: 10),
                                // child: Flexible(
                                //   child: _Timeline(
                                //     order: appState.order!,
                                //   ),
                                // ),
                              ),
                          ),
                    ),
                    const Align(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }
}

class _Timeline extends StatelessWidget {
  final Order order;

  const _Timeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    List<OrderStatus> data = OrderStatus.values;

    return Flexible(
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          nodeItemOverlap: true,
          connectorTheme: const ConnectorThemeData(
            color: Color(0xffe6e7e9),
            thickness: 5.0,
          ),
        ),
        padding: const EdgeInsets.only(top: 20.0),
        builder: TimelineTileBuilder.connected(
          indicatorBuilder: (context, index) {
            final status = data[index];
            return OutlinedDotIndicator(
              color: data.indexOf(order.status) >= index
                  ? Colors.black
                  : Colors.white,
              backgroundColor: data.indexOf(order.status) >= index
                  ? Colors.black
                  : Colors.white,
              borderWidth: 1,
            );
          },
          connectorBuilder: (context, index, connectorType) {
            var color;
            if (index + 1 < data.length - 1) {
              color = data.indexOf(order.status) > index
                  ? Colors.black
                  : Colors.white;
            }
            return SolidLineConnector(
              color: color,
            );
          },
          contentsBuilder: (context, index) {
            return Container(
              height: 40,
              margin: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  data[index].value,
                  style: TextStyle(
                    color: data.indexOf(order.status) >= index
                        ? Colors.black
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: data.indexOf(order.status) >= index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
          itemCount: data.length,
        ),
      ),
    );
  }
}
