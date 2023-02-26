import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  String hint;

  CustomTextField({Key? key, required this.controller, required this.hint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        autocorrect: false,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}

class CustomButtonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function() pick;

  const CustomButtonTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.pick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              autocorrect: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
          IconButton(
            onPressed: pick,
            icon: const Icon(
              Icons.pin_drop,
              color: primaryColor,
            ),
          )
        ],
      ),
    );
  }
}
