import 'package:app/notifications/system_notification.dart';
import 'package:flutter/material.dart';
import 'package:app/model/medicaments.dart';
import 'package:app/model/reminders.dart';
import 'package:app/widgets/calendar_widget.dart';
import 'package:app/widgets/medication_reminder_card_widget.dart';
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

  Future<List<Reminder>> getReminders() async {
    return await ReminderDatabase().getReminders();
  }

  void refreshReminderList() async {
    setState(() {
      _remindersFuture = getReminders();
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

  Widget _buildMedicationReminderWidget() {
    return FutureBuilder<void>(
      // Delay used to fix small visual bug
      future: Future.delayed(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          return _buildReminderList();
        }
      },
    );
  }

  Widget _buildReminderList() {
    return FutureBuilder<List<Reminder>>(
      future: _remindersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          List<Reminder>? reminders = snapshot.data;
          if (reminders != null && reminders.isNotEmpty) {
            List<Reminder> applicableReminders = _getApplicableReminders(
                reminders);
            if (applicableReminders.isNotEmpty) {
              return _buildReminderCardInfoList(applicableReminders);
            }
          }
          return noRemindersCard();
        }
      },
    );
  }

  List<Reminder> _getApplicableReminders(List<Reminder> reminders) {
    return reminders.where((reminder) {
      int selectedDayIndex = _selectedDay.weekday % 7;
      bool isBeforeOrAtEndDate = reminder.endDate.isAfter(
          _selectedDay.subtract(const Duration(days: 1))) ||
          reminder.endDate.isAtSameMomentAs(_selectedDay);
      bool isAfterStartDate = reminder.startDate.isBefore(_selectedDay) ||
          reminder.startDate.isAtSameMomentAs(_selectedDay);
      bool isSelectedDay = reminder.selectedDays[selectedDayIndex];

      return isBeforeOrAtEndDate && isAfterStartDate && isSelectedDay;
    }).toList();
  }

  Widget _buildReminderCardInfoList(List<Reminder> applicableReminders) {
    return FutureBuilder<List<_ReminderCardInfo>>(
      future: _getReminderCardInfos(applicableReminders),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          List<_ReminderCardInfo> reminderCardInfos = snapshot.data!;
          reminderCardInfos.sort((a, b) =>
              _compareTimeOfDay(a.reminderCard.time, b.reminderCard.time));

          return _buildReminderCardsColumn(reminderCardInfos);
        }
      },
    );
  }

  Widget _buildReminderCardsColumn(List<_ReminderCardInfo> reminderCardInfos) {
    return Column(
        children: [
          ...reminderCardInfos.map((info) {
            return MedicationReminderCard(
              cardId: info.reminderCard.cardId,
              reminderId: info.reminderCard.reminderId,
              medicament: info.medicament,
              day: info.reminderCard.day,
              time: info.reminderCard.time,
              intakeQuantity: info.reminderCard.intakeQuantity,
              isTaken: info.reminderCard.isTaken,
              isJumped: info.reminderCard.isJumped,
              pressedTime: info.reminderCard.pressedTime,
            );
          }),
          const SizedBox(height: 150),
        ],
    );
  }

  Future<List<_ReminderCardInfo>> _getReminderCardInfos(List<Reminder> reminders) async {
    List<_ReminderCardInfo> reminderCardInfos = [];
    for (var reminder in reminders) {
      Medicament? medicament = await MedicamentStock().getMedicamentById(reminder.medicament);
      List<ReminderCard> reminderCards = await ReminderDatabase().getReminderCards(reminder.id, _selectedDay);
      for (var reminderCard in reminderCards) {
        reminderCardInfos.add(_ReminderCardInfo(reminderCard, reminder, medicament!));
      }
    }
    return reminderCardInfos;
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    int hourComparison = a.hour.compareTo(b.hour);
    if (hourComparison != 0) {
      return hourComparison;
    } else {
      return a.minute.compareTo(b.minute);
    }
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

class _ReminderCardInfo {
  final ReminderCard reminderCard;
  final Reminder reminder;
  final Medicament medicament;

  _ReminderCardInfo(this.reminderCard, this.reminder, this.medicament);
}
