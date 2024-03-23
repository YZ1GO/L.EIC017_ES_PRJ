import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background shape
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 244, 236, 1), // Background color of the shape
              borderRadius: BorderRadius.circular(0), // Border radius of the shape
            ),
          ),
          // Content
          const Center(
            child: Text(
              'Home Screen',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
