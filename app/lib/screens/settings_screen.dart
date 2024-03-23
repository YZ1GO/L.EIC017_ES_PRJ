import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1), // Background color
      body: Stack(
        children: [
          Center(
            child: Text('Settings Screen'),
          ),
          Positioned(
            left: -206,
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
