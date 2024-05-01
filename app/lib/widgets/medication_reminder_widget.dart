import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../medicaments.dart';
import '../reminders.dart';

class MedicationReminderWidget extends StatelessWidget {
  final int reminderId;
  final String reminderName;
  final DateTime selectedDay;
  final Medicament? medicament;

  const MedicationReminderWidget({super.key,
    required this.reminderId,
    required this.reminderName,
    required this.selectedDay,
    required this.medicament,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      // Delay used to fix small visual bug
      future: Future.delayed(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(); // Return an empty SizedBox while waiting
        } else {
          return FutureBuilder<List<ReminderCard>>(
            future: ReminderDatabase().getReminderCards(reminderId, selectedDay),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(); // Return an empty SizedBox while waiting
              } else if (snapshot.hasData) {
                final List<ReminderCard> reminderCards = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reminderCards.map((reminderCard) {
                    return MedicationReminderCard(
                      cardId: reminderCard.cardId,
                      reminderId: reminderCard.reminderId,
                      medicament: medicament,
                      day: reminderCard.day,
                      time: reminderCard.time,
                      isTaken: reminderCard.isTaken,
                      isJumped: reminderCard.isJumped,
                      pressedTime: reminderCard.pressedTime,
                      onPressed: () {
                        // Handle onPressed event if needed
                      },
                    );
                  }).toList(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const SizedBox();
              }
            },
          );
        }
      },
    );
  }
}

class MedicationReminderCard extends StatefulWidget {
  final String cardId;
  final int reminderId;
  final Medicament? medicament;
  final DateTime day;
  final TimeOfDay time;
  final bool isTaken;
  final bool isJumped;
  final TimeOfDay? pressedTime;
  final VoidCallback onPressed;

  const MedicationReminderCard({
    required this.cardId,
    required this.reminderId,
    required this.medicament,
    required this.day,
    required this.time,
    required this.isTaken,
    required this.isJumped,
    this.pressedTime,
    required this.onPressed,
  });

  @override
  MedicationReminderCardState createState() => MedicationReminderCardState();
}

class MedicationReminderCardState extends State<MedicationReminderCard> {
  late TimeOfDay? pressedTime;
  late bool isTaken;

  @override
  void initState() {
    super.initState();
    pressedTime = widget.pressedTime;
    isTaken = widget.isTaken;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          color: isTaken ? const Color.fromRGBO(255, 122, 0, 1) : const Color.fromRGBO(255, 218, 190, 1),
          child: SizedBox(
            height: 150,
            child: Stack(
              children: [
                // Specifics of medication
                Stack(
                  children: [
                    // Three dots icon
                    Positioned(
                      top: 20,
                      right: 18,
                      child: Icon(
                        FontAwesomeIcons.ellipsisVertical,
                        size: 15,
                        color: isTaken ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  FontAwesomeIcons.solidClock,
                                  size: 15,
                                  color: isTaken ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.time.format(context),
                                style: TextStyle(
                                  fontFamily: 'Open_Sans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isTaken ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.medicament!.name,
                            style: TextStyle(
                              fontFamily: 'Open_Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isTaken ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
                            ),
                          ),
                          if (isTaken) ...[
                            const Text(
                              'Taken',
                              style: TextStyle(
                                fontFamily: 'Open_Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // White tick after taken
                    if (isTaken) ...[
                      const Positioned(
                        top: -5,
                        right: -25,
                        child: Icon(
                          FontAwesomeIcons.check,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                // Take button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          if (isTaken) {
                            isTaken = false;
                            pressedTime = null;
                          } else {
                            isTaken = true;
                            pressedTime = TimeOfDay.now();
                          }
                        });

                        final updatedCard = ReminderCard(
                          cardId: widget.cardId,
                          reminderId: widget.reminderId,
                          day: widget.day,
                          time: widget.time,
                          isTaken: isTaken,
                          isJumped: widget.isJumped,
                          pressedTime: pressedTime,
                        );

                        await ReminderDatabase().updateReminderCard(updatedCard);

                        widget.onPressed();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        backgroundColor: const Color.fromRGBO(225, 95, 0, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isTaken
                            ? '${pressedTime!.hour.toString().padLeft(2, '0')}:${pressedTime!.minute.toString().padLeft(2, '0')}'
                            : 'Take',
                        style: const TextStyle(
                          fontFamily: 'Open_Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
