import 'package:flutter/material.dart';
import 'package:app/screens/search_screen.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          Center(
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
            )
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
