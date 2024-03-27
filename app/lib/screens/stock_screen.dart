import 'package:app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/search_screen.dart';
import '../widgets/eclipse_background.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          eclipse_background(),
          Positioned(
            left: 0,
            right: 0,
            top: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
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
                    foregroundColor: Color.fromRGBO(225, 95, 0, 1),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.5),
                    backgroundColor: Color.fromRGBO(255, 220, 194, 1),
                    foregroundColor: Color.fromRGBO(225, 95, 0, 1),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
