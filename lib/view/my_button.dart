import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.icon,
    required this.text,
    this.width,
    this.height,
  }) : super(key: key);

  final IconData? icon;
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final Function() onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: height??45.h,
            width: width??MediaQuery.of(context).size.width * .6,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            margin:  const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(9),
              color: backgroundColor??Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon == null? const SizedBox(): Icon(
                  icon,
                  color: textColor??Colors.white,
                  size: 30.sp,
                ),
                Expanded(
                    child: Center(
                        child: Text(
                          'Add Order',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        )))
              ],
            ),
          )),
    );
  }
}