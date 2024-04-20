import 'package:flutter/material.dart';
import '../reminders.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/medication_reminder_widget.dart';
import '../widgets/eclipse_background.dart';

late Future<List<Reminder>> _remindersFuture;

class HomeScreen extends StatefulWidget {
  final VoidCallback onReminderSaved;

  const HomeScreen({super.key, required this.onReminderSaved});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _remindersFuture = getReminders();
  }

  void _handleDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshReminderList();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          eclipse_background(),
          CalendarWidget(
            onDaySelected: _handleDaySelected,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 250,
            child: _buildMedicationReminderWidget(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 700,
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
          List<Reminder> applicableReminders = reminders.where((reminder) {
            if (reminder.startDate.isBefore(_selectedDay) ||
                reminder.startDate.isAtSameMomentAs(_selectedDay)) {
              int selectedDayIndex = _selectedDay.weekday % 7;
              return reminder.selectedDays[selectedDayIndex];
            }
            return false;
          }).toList();
          if (applicableReminders.isNotEmpty) {
            return Column(
              children: applicableReminders.map((reminder) {
                return MedicationReminderWidget(
                  reminderName: reminder.reminderName,
                  selectedDays: reminder.selectedDays,
                  startDay: reminder.startDate,
                  medicamentName: reminder.medicament,
                  times: reminder.times,
                );
              }).toList(),
            );
          }
        }
        return noRemindersCard();
      },
    );
  }

  void _clearRemindersDatabase() async {
    await ReminderDatabase().clearReminders();
    setState(() {
      _remindersFuture = getReminders();
    });
  }

  Widget noRemindersCard() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          color: const Color.fromRGBO(255, 218, 190, 1),
          child: const SizedBox(
            height: 150,
            child: Center(
              child: Text(
                "There is no registered pill",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(225, 95, 0, 1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
