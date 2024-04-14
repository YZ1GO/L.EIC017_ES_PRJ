import 'package:flutter/material.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/medicament_reminder_widget.dart';
import '../widgets/system_notification_test_widget.dart';
import '../widgets/eclipse_background.dart';
import 'database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          eclipse_background(),
          const CalendarWidget(),
          Positioned(
            left: 0,
            right: 0,
            top: 250,
            child: MedicationReminderWidget(
              medicamentName: 'Paracetamol', // Default medicament name
              dayAdded: DateTime.now(), // Today's date
              frequencies: [
                TimeOfDay(hour: 12, minute: 0),
                TimeOfDay(hour: 16, minute: 0),
                TimeOfDay(hour: 20, minute: 0),
              ], // Custom frequency
            ),
          ),
          /*Positioned(
            left: 0,
            right: 0,
            top: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await requestNotificationPermission(context);
                  },
                  icon: Icon(Icons.notifications_active),
                  label: Text('Test notification'),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.5),
                    backgroundColor: Color.fromRGBO(255, 131, 41, 1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DatabaseContentScreen()),
                    );
                  },
                  icon: Icon(Icons.cloud),
                  label: Text('Firebase Database'),
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
          ),*/
        ],
      ),
    );
  }
}
