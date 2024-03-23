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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: kBottomNavigationBarHeight + 12,
            left: (MediaQuery.of(context).size.width - 125) / 2,
            child: RawMaterialButton(
              onPressed: () {
                showPopup(context);
              },
              elevation: 0,
              fillColor: Colors.transparent,
              child:
                Image.asset(
                  'assets/pingu-transparent-shadow.png',
                  width: 120,
                  height: 120,
                ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 83,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 14,
                offset: Offset(0, -1),
              )
            ],
          ),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () => onItemTapped(0),
                    color: selectedIndex == 0 ? Color.fromRGBO(185, 137, 102, 1) : Color.fromRGBO(230, 217, 206, 1),
                    iconSize: 32,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () => onItemTapped(1),
                    color: selectedIndex == 1 ? Color.fromRGBO(185, 137, 102, 1) : Color.fromRGBO(230, 217, 206, 1),
                    iconSize: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
