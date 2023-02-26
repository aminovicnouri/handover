
part of '../orders_bottom_sheet.dart';

class OrderListWidget extends StatelessWidget {
  const OrderListWidget(
      {Key? key,
        required this.bottomSheetBloc,
        required this.selectOrder,
        required this.allOrders})
      : super(key: key);

  final List<Order> allOrders;
  final BottomSheetBloc bottomSheetBloc;
  final Function(Order order) selectOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40.h,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 40.h),
            itemCount: allOrders.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                if(allOrders[index].status != OrderStatus.submitted) {
                  bottomSheetBloc.add(SelectOrderBottomSheetEvent(
                      order: allOrders[index], select: selectOrder));
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.amber[500],
                  boxShadow: const [BoxShadow(
                    color: Colors.black45,
                    blurRadius: 5,
                    offset: Offset(1,2),
                  )]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allOrders[index].name,
                          style:
                          TextStyle(color: Colors.black, fontSize: 20.sp , fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Address : ${allOrders[index].address}',
                          style:
                          TextStyle(color: Colors.black, fontSize: 16.sp),
                        ),
                      ],
                    ),
                    Text(
                      allOrders[index].status.value,
                      style: TextStyle(fontSize: 16.sp , color: Colors.black , fontWeight: FontWeight.bold),
                    ),
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
    );
  }
}