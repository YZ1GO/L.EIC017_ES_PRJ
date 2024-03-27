import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isToggleEnabled;

  @override
  void initState() {
    super.initState();
    isToggleEnabled = false;
    loadToggleState();
  }

  Future<void> loadToggleState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isToggleEnabled = prefs.getBool('toggle') ?? false;
    });
  }

  Future<void> saveToggleState(bool newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('toggle', newValue);
    setState(() {
      isToggleEnabled = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToggleEnabled ? 'Enabled' : 'Disabled',
              style: TextStyle(
                color: isToggleEnabled ? Colors.red : null,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Switch(
              value: isToggleEnabled,
              onChanged: (newValue) {
                saveToggleState(newValue);
              },
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

}
