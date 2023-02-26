import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:handover/bloc/bottomSheet/bottom_sheet_bloc.dart';
import 'package:handover/model/order.dart';
import 'package:handover/utils/constants.dart';
import 'package:handover/view/my_button.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';

class OrdersBottomSheet extends StatelessWidget {
  const OrdersBottomSheet({
    required this.bottomSheetBloc,
    required this.selectOrder,
    required this.updateOrder,
    required this.clearSelection,
    Key? key,
  }) : super(key: key);

  final Function(Order order) selectOrder;
  final Function(Order order) updateOrder;
  final Function() clearSelection;
  final BottomSheetBloc bottomSheetBloc;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BottomSheetBloc, BottomSheetState>(
      bloc: bottomSheetBloc..add(Initialize(select: selectOrder)),
      listener: (context, state) {},
      builder: (context, appState) {
        return SizedBox(
          height: appState.currentOrder == null ? 500.h : 500.h,
          child: Stack(
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: 60.h,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: appState.currentOrder == null
                          ? Alignment.center
                          : Alignment.centerLeft,
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 0.h),
                      padding: EdgeInsets.only(bottom: 0.h),
                      decoration: const BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          )),
                      child: appState.currentOrder == null
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 40.h,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(top: 40.h),
                                    itemCount: appState.allOrders.length,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () {
                                        bottomSheetBloc.add(
                                            SelectOrderBottomSheetEvent(
                                                order:
                                                    appState.allOrders[index],
                                                select: selectOrder));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        padding: EdgeInsets.all(10.sp),
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
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20.sp),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  appState
                                                      .allOrders[index].address,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16.sp),
                                                ),
                                              ],
                                            ),
                                            ElevatedButton(
                                              onPressed: () {},
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  appState.allOrders[index]
                                                      .status.value,
                                                  style: TextStyle(
                                                      fontSize: 14.sp),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                MyButton(
                                  text: 'Add Order',
                                  onTap: () {
                                    context.go('/addOrder');
                                  },
                                  icon: Icons.add_circle,
                                ),
                              ],
                            )
                          : appState.currentOrder!.status !=
                                  OrderStatus.delivered
                              ? Container(
                                  margin: EdgeInsets.only(
                                    top: 100.h,
                                    left: 10.w,
                                    right: 10.w,
                                  ),
                                  child: Stack(
                                    children: [
                                      _Timeline(
                                        order: appState.currentOrder!,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: appState.canBePickedOrDelivered
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  bottomSheetBloc
                                                      .add(UpdateOrderEvent(
                                                    order:
                                                        appState.currentOrder!,
                                                    canBePickedOrDelivered:
                                                        true,
                                                    updateOrder: updateOrder,
                                                  ));
                                                },
                                                child: Text(
                                                  appState.currentOrder!
                                                              .status ==
                                                          OrderStatus
                                                              .runningForPickUp
                                                      ? "Confirm pick up"
                                                      : "Confirm delivery",
                                                ))
                                            : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  margin: const EdgeInsets.only(top: 100),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      RatingBar.builder(
                                        initialRating: 1,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                        ),
                                        onRatingUpdate: (rating) {
                                          bottomSheetBloc.add(
                                              UpdateOrderRatingEvent(
                                                  rating: rating));
                                        },
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const Text(
                                                "Pickup time: ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                DateFormat('hh:mm a').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    (appState.currentOrder!
                                                            .pickUpTime!)
                                                        .toInt(),
                                                  ).toLocal(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const Text(
                                                "Deliver time: ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                DateFormat('hh:mm a').format(
                                                  DateTime.fromMillisecondsSinceEpoch(
                                                          (appState
                                                                  .currentOrder!
                                                                  .deliveryTime!)
                                                              .toInt())
                                                      .toLocal(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    "Total",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    '\$ ${appState.currentOrder!.price}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                              child: Align(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () {
                                                bottomSheetBloc.add(
                                                    SubmitOrderEvent(
                                                        order: appState
                                                            .currentOrder!,
                                                        clear: clearSelection));
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: const [
                                                      Text(
                                                        "Submit",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        size: 18,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 70.sp,
                      backgroundImage:
                          const AssetImage('assets/images/luna_pic.jpeg'),
                      //backgroundColor: Colors.red,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    appState.currentOrder != null
                        ? Text(
                            appState.currentOrder!.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.sp),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Timeline extends StatelessWidget {
  final Order order;

  const _Timeline({required this.order});

  @override
  Widget build(BuildContext context) {
    List<OrderStatus> data = OrderStatus.values;

    return Timeline.tileBuilder(
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
          Color? color;
          if (index + 1 < data.length - 1) {
            color = data.indexOf(order.status) > index
                ? Colors.black
                : Colors.white;
          }
          return SolidLineConnector(
            color: color ?? Colors.white,
          );
        },
        contentsBuilder: (context, index) {
          return Container(
            height: 40.h,
            margin: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data[index].value,
                style: TextStyle(
                  color: data.indexOf(order.status) >= index
                      ? Colors.black
                      : Colors.white,
                  fontSize: 16.sp,
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
    );
  }
}
