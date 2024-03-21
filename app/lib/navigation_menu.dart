import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  NavigationMenuState createState() => NavigationMenuState();
}

class NavigationMenuState extends State<NavigationMenu> {
  int selectedIndex = 0;

  static final List<Widget> screens = <Widget>[
    const HomeScreen(),
    const SettingsScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Popup"),
          content: const Text("This is a popup."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Vertical Prototype'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      floatingActionButton: Stack( // Wrap the Positioned widget with a Stack
        children: [
          Positioned(
            bottom: kBottomNavigationBarHeight + 10,
            left: (MediaQuery.of(context).size.width - 125) / 2,
            child: RawMaterialButton(
              onPressed: () {
                showPopup(context);
              },
              elevation: 0,
              fillColor: Colors.transparent,
              child: Image.asset(
                'assets/pingu_transparent.png',
                width: 125, // Adjust width as needed
                height: 125, // Adjust height as needed
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.blue, // Set the background color
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), // Adjust the radius as needed
            topRight: Radius.circular(20), // Adjust the radius as needed
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () => onItemTapped(0),
                color: selectedIndex == 0 ? Colors.deepOrange : Colors.grey,
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => onItemTapped(1),
                color: selectedIndex == 1 ? Colors.deepOrange : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
