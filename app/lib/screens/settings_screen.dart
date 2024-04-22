import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int lowQuantity;
  late int daysBeforeExpiry;

  @override
  void initState() {
    super.initState();
    lowQuantity = 0;
    daysBeforeExpiry = 1;
    loadLowQuantity();
    loadDaysBeforeExpiry();
  }

  Future<void> loadLowQuantity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lowQuantity = prefs.getInt('lowQuantity') ?? 0;
    });
  }

  Future<void> saveLowQuantity(int newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lowQuantity', newValue);
    setState(() {
      lowQuantity = newValue;
    });
  }

  Future<void> loadDaysBeforeExpiry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      daysBeforeExpiry = prefs.getInt('daysBeforeExpiry') ?? 1;
    });
  }

  Future<void> saveDaysBeforeExpiry(int newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daysBeforeExpiry', newValue);
    setState(() {
      daysBeforeExpiry = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromRGBO(158, 66, 0, 1),
                  ),
                ),
                Divider(color: Color.fromRGBO(158, 66, 0, 0.5)),
                SizedBox(height: 16),
                Text(
                  'Quantity to notify low stock',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color.fromRGBO(158, 66, 0, 1),
                  ),
                ),
                SizedBox(height: 6.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(225, 95, 0, 1),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (lowQuantity > 1) lowQuantity--;
                            saveLowQuantity(lowQuantity);
                          });
                        },
                      ),
                      Text(
                        '$lowQuantity',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            lowQuantity++;
                            saveLowQuantity(lowQuantity);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Days before medicament expiry',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color.fromRGBO(158, 66, 0, 1),
                  ),
                ),
                SizedBox(height: 6.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(225, 95, 0, 1),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (daysBeforeExpiry > 1) daysBeforeExpiry--;
                            saveDaysBeforeExpiry(daysBeforeExpiry);
                          });
                        },
                      ),
                      Text(
                        '$daysBeforeExpiry',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            daysBeforeExpiry++;
                            saveDaysBeforeExpiry(daysBeforeExpiry);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }
}
