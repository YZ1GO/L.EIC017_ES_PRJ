import 'package:app/notifications/system_notification.dart';
import 'package:flutter/material.dart';
import 'package:app/model/medicaments.dart';
import 'package:app/model/reminders.dart';
import 'package:app/widgets/calendar_widget.dart';
import 'package:app/widgets/medication_reminder_widget.dart';
import 'package:app/widgets/eclipse_background.dart';
import 'package:app/database/local_stock.dart';

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

  void refreshMedicationReminders() {
    setState(() {});
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
            top: 230,
            bottom: MediaQuery.of(context).size.height * 0.05,
            child: SingleChildScrollView(
              child: _buildMedicationReminderWidget(),
            ),
          ),
          Positioned(
            left: 300,
            right: 0,
            top: 50,
            child: ElevatedButton(
              onPressed: _clearRemindersDatabase,
              child: Text('Clear'),
            ),
          ),
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
        if (reminders != null && reminders.isNotEmpty) {
          List<Reminder> applicableReminders = reminders.where((reminder) {
            int selectedDayIndex = _selectedDay.weekday % 7;
            bool isBeforeOrAtEndDate = reminder.endDate.isAfter(_selectedDay.subtract(const Duration(days: 1))) ||
                reminder.endDate.isAtSameMomentAs(_selectedDay);
            bool isAfterStartDate = reminder.startDate.isBefore(_selectedDay) ||
                reminder.startDate.isAtSameMomentAs(_selectedDay);
            bool isSelectedDay = reminder.selectedDays[selectedDayIndex];

            return isBeforeOrAtEndDate && isAfterStartDate && isSelectedDay;
          }).toList();

          applicableReminders.sort((a, b) {
            return a.times[0].hour.compareTo(b.times[0].hour);
          });

          if (applicableReminders.isNotEmpty) {
            return Column(
              children: [
                ...applicableReminders.map((reminder) {
                  return FutureBuilder<Medicament?>(
                    future: MedicamentStock().getMedicamentById(reminder.medicament),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        return MedicationReminderWidget(
                          reminderId: reminder.id,
                          reminderName: reminder.reminderName,
                          selectedDay: _selectedDay,
                          medicament: snapshot.data!,
                        );
                      }
                    },
                  );
                }),
                const SizedBox(height: 150),
              ],
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
    cancelAllNotifications();
    checkScheduledNotifications();
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
