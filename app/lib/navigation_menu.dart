import 'package:flutter/material.dart';
import 'medicaments.dart';
import 'screens/home_screen.dart';
import 'screens/stock_screen.dart';
import 'controlCenter.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  NavigationMenuState createState() => NavigationMenuState();
}

late Future<List<Medicament>> _medicaments;

class NavigationMenuState extends State<NavigationMenu> {

  Future<List<Medicament>> getMedicaments() async {
    return await MedicamentStock().getMedicaments();
  }

  void refreshStockList() {
    setState(() {
      print("here");
      _medicaments = getMedicaments();
    });
  }

  void _refreshHomeScreenOnReminderSaved() {
    setState(() {});
  }

  int selectedIndex = 0;

  List<Widget> get screens => [
    HomeScreen(onReminderSaved: _refreshHomeScreenOnReminderSaved),
    StockScreen(selectionMode: false, medicamentList: _medicaments),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      if (selectedIndex == 1) refreshStockList();
    });
  }

  @override
  void initState() {
    super.initState();
    refreshStockList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
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
            bottom: kBottomNavigationBarHeight + 10,
            left: (MediaQuery.of(context).size.width - 150) / 2,
            child: MaterialButton(
              onPressed: () {
                showControlCenter(context, _refreshHomeScreenOnReminderSaved);
              },
              elevation: 0,
              highlightElevation: 0,
              color: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Image.asset(
                'assets/icons/pingu-transparent-shadow.png',
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
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        selectedIndex == 0 ? const Color.fromRGBO(185, 137, 102, 1) : const Color.fromRGBO(230, 217, 206, 1),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/icons/pills_icon_2.png',
                        width: 31,
                        height: 31,
                      ),
                    ),
                    onPressed: () => onItemTapped(0),
                    highlightColor: Colors.transparent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                    key: Key('stock screen button'),
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        selectedIndex == 1 ? const Color.fromRGBO(185, 137, 102, 1) : const Color.fromRGBO(230, 217, 206, 1),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/icons/box_icon.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    onPressed: () => onItemTapped(1),
                    highlightColor: Colors.transparent,
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
