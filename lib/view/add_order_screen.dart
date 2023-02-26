import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:handover/bloc/add_order/add_order_bloc.dart';
import 'package:handover/repositories/order_repository_Impl.dart';
import 'package:handover/view/text_field.dart';

import '../utils/constants.dart';

class AddOrderScreen extends HookWidget {
  const AddOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final addressController = useTextEditingController();
    final priceController = useTextEditingController();
    final pickupController = useTextEditingController();
    final deliveryController = useTextEditingController();

    GeoPoint? pickup;
    GeoPoint? delivery;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add order"),
        backgroundColor: primaryColor,
      ),
      body: RepositoryProvider(
        create: (context) => OrderRepositoryImpl(),
        child: BlocProvider<AddOrderBloc>(
          create: (context) => AddOrderBloc(
              orderRepository: context.read<OrderRepositoryImpl>()),
          child: BlocConsumer<AddOrderBloc, AddOrderState>(
            listener: (context, state) {
              if(state is OrderAdded) {
                nameController.clear();
                addressController.clear();
                priceController.clear();
                pickupController.clear();
                deliveryController.clear();
                pickup = null;
                delivery = null;
              }
            },
            builder: (context, state) {
              return state is AddOrderInitial
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 100,
                          ),
                          CustomTextField(
                              controller: nameController, hint: "Name"),
                          CustomTextField(
                              controller: addressController, hint: "Address"),
                          CustomTextField(
                              controller: priceController, hint: "Price"),
                          CustomButtonTextField(
                            controller: pickupController,
                            hint: "..",
                            pick: () async {
                              pickup = await showSimplePickerLocation(
                                  context: context,
                                  isDismissible: true,
                                  title: "Pick up",
                                  textConfirmPicker: "pick",
                                  initCurrentUserPosition: true,
                                  initZoom: 15);
                              pickupController.text =
                                  "${pickup?.latitude},${pickup?.longitude}";
                            },
                          ),
                          CustomButtonTextField(
                            controller: deliveryController,
                            hint: "..",
                            pick: () async {
                              delivery = await showSimplePickerLocation(
                                  context: context,
                                  isDismissible: true,
                                  title: "Delivery",
                                  textConfirmPicker: "pick",
                                  initCurrentUserPosition: true,
                                  initZoom: 15);
                              deliveryController.text =
                                  "${delivery?.latitude},${delivery?.longitude}";
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          state.missingFields
                              ? const Center(
                                  child: Text(
                                    'Missing values',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                              ),
                              onPressed: () {
                                context
                                    .read<AddOrderBloc>()
                                    .add(AddOrderToDatabaseEvent(
                                      name: nameController.text,
                                      address: addressController.text,
                                      price: priceController.text,
                                      pickup: pickup,
                                      delivery: delivery,
                                    ));
                              },
                              child: const Text(
                                'Add Order',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    )
                  : Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                minimumSize: const Size(150, 40)
                              ),
                              onPressed: () {
                                context
                                    .read<AddOrderBloc>()
                                    .add(AddMoreOrderEvent());
                              },
                              child: const Text(
                                'Add more',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                          const SizedBox(height: 20,),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                minimumSize: const Size(150, 40)
                              ),
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text(
                                'Back to home',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
              ),
                  );
            },
          ),
        ),
      ),
    );
  }
}
