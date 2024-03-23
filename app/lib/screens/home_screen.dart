import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          Center(
            child: Text('Home Screen'),
          ),
          Positioned(
            left: (MediaQuery.of(context).size.width - 801) / 2, // Adjust position to center horizontally
            top: -268,
            child: ClipOval(
              child: Container(
                width: 801,
                height: 553,
                color: Color.fromRGBO(225, 95, 0, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
