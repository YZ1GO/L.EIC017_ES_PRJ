import 'package:flutter/material.dart';
import 'package:app/model/medicaments.dart';
import 'package:app/model/reminders.dart';
import 'package:app/widgets/calendar_widget.dart';
import 'package:app/widgets/medication_reminder_card_widget.dart';
import 'package:app/widgets/elipse_background.dart';
import 'package:app/database/local_medicament_stock.dart';

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
      _buildMedicationReminderWidget();
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshReminderList();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          const ElipseBackground(),
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
            return FutureBuilder<List<ReminderWithCards>>(
              future: _getApplicableReminders(reminders),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                } else {
                  List<ReminderWithCards>? applicableReminders = snapshot.data;
                  if (applicableReminders != null && applicableReminders.isNotEmpty) {
                    return _buildReminderCardInfoList(applicableReminders);
                  }
                }
                return noRemindersCard();
              },
            );
          } else {
            return noRemindersCard();
          }
        }
      },
    );
  }

  Future<List<ReminderWithCards>> _getApplicableReminders(List<Reminder> reminders) async {
    List<ReminderWithCards> applicableReminders = [];

    for (Reminder reminder in reminders) {
      List<ReminderCard> reminderCards = await ReminderDatabase().getReminderCardsForSelectedDay(reminder.id, _selectedDay);
      if (reminderCards.isNotEmpty) {
        applicableReminders.add(ReminderWithCards(reminder, reminderCards));
      }
    }

    return applicableReminders;
  }

  Widget _buildReminderCardInfoList(List<ReminderWithCards> applicableReminders) {
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
              onCardUpdated: (updatedCard) {
                  // Find the index of the reminder card in the list
                  int index = reminderCardInfos.indexWhere((info) => info.reminderCard.cardId == updatedCard.cardId);

                  // Update the reminder card in the list
                  if (index != -1) {
                    reminderCardInfos[index] = _ReminderCardInfo(updatedCard, reminderCardInfos[index].reminder, reminderCardInfos[index].medicament);
                  }
              },
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

  Future<List<_ReminderCardInfo>> _getReminderCardInfos(List<ReminderWithCards> reminderWithCardsList) async {
    List<_ReminderCardInfo> reminderCardInfos = [];
    for (var reminderWithCards in reminderWithCardsList) {
      Medicament? medicament = await MedicamentStock().getMedicamentById(reminderWithCards.reminder.medicament);
      for (var reminderCard in reminderWithCards.reminderCards) {
        reminderCardInfos.add(_ReminderCardInfo(reminderCard, reminderWithCards.reminder, medicament!));
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
                "No reminders for today",
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

class ReminderWithCards {
  final Reminder reminder;
  final List<ReminderCard> reminderCards;

  ReminderWithCards(this.reminder, this.reminderCards);
}

class _ReminderCardInfo {
  final ReminderCard reminderCard;
  final Reminder reminder;
  final Medicament medicament;

  _ReminderCardInfo(this.reminderCard, this.reminder, this.medicament);
}
