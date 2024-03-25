import 'package:flutter/material.dart';
import 'package:app/screens/search_screen.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child:
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
                icon: Icon(Icons.search),
                label: Text('Search Medication'),
                style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.5),
                    backgroundColor: Color.fromRGBO(255, 220, 194, 1),
                    foregroundColor: Color.fromRGBO(225, 95, 0, 1)
                ),
              ),
            ),
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
