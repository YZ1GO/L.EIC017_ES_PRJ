import 'package:flutter/material.dart';

class eclipse_background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (MediaQuery.of(context).size.width - 801) / 2,
      top: -268,
      child: ClipOval(
        child: Container(
          width: 801,
          height: 553,
          color: const Color.fromRGBO(225, 95, 0, 1),
        ),
      ),
    );
  }
}
