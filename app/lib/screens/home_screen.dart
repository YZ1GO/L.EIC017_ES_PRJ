import 'package:flutter/material.dart';
import '../reminders.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/medication_reminder_widget.dart';
import '../widgets/eclipse_background.dart';

late Future<List<Reminder>> _remindersFuture;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _remindersFuture = getReminders();
  }

  @override
  Widget build(BuildContext context) {
    refreshReminderList();
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
            child: _buildMedicationReminderWidget(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 100,
            child: ElevatedButton(
              onPressed: _clearRemindersDatabase,
              child: Text('Clear Reminders'),
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

  Future<List<Reminder>> getReminders() async {
    return await ReminderDatabase().getReminders();
  }

  void refreshReminderList() async {
    setState(() {
      _remindersFuture = getReminders();
    });
  }

  Widget _buildMedicationReminderWidget() {
    return FutureBuilder<List<Reminder>>(
      future: _remindersFuture,
      builder: (context, snapshot) {
        List<Reminder>? reminders = snapshot.data;
        print('Reminders ${reminders?.length ?? 0}');
        if (reminders != null && reminders.isNotEmpty) {
          final Reminder firstReminder = reminders.first;
          return MedicationReminderWidget(
            reminderName: firstReminder.reminderName,
            selectedDays: firstReminder.selectedDays,
            startDay: firstReminder.startDate,
            medicamentName: firstReminder.medicament,
            times: firstReminder.times,
          );
        } else {
          return Text('No reminders found');
        }
      },
    );
  }

  void _clearRemindersDatabase() async {
    await ReminderDatabase().clearReminders();
    setState(() {
      _remindersFuture = Future.value([]); // Reset future to empty list
    });
  }
}
