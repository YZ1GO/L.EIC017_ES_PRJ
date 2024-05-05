import 'package:flutter/material.dart';
import 'package:app/screens/add_reminder_screen.dart';
import 'package:app/screens/settings_screen.dart';
import '../model/medicaments.dart';

void showControlCenter(BuildContext context, VoidCallback onReminderSaved, Future<List<Medicament>> medicamentList, VoidCallback onMedicamentListUpdated) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 259,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 50),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReminderPage(
                              onReminderSaved: onReminderSaved,
                              medicamentList: medicamentList,
                              onMedicamentListUpdated: onMedicamentListUpdated,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromRGBO(225, 95, 0, 1),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      icon: Image.asset(
                        'assets/icons/alarm_icon.png',
                        width: 17,
                      ),
                      label: Text("Add reminder"),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromRGBO(199, 84, 0, 1),
                        backgroundColor: Color.fromRGBO(255, 198, 157, 1),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      icon: Image.asset(
                        'assets/icons/calendar_icon.png',
                        width: 17,
                      ),
                      label: Text("Manage reminders"),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromRGBO(199, 84, 0, 1),
                        backgroundColor: Color.fromRGBO(255, 198, 157, 1),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      icon: Icon(
                        Icons.settings,
                        size: 17,
                      ),
                      label: Text("Settings"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 242,
            left: (MediaQuery.of(context).size.width - 120) / 2,
            child:
            Image.asset(
              'assets/icons/pingu-transparent-shadow.png',
              width: 120,
              height: 120,
            ),
          ),
        ],
      );
    },
  );
}
