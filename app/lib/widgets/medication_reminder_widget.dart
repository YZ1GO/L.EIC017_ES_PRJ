import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/model/medicaments.dart';
import 'package:app/database/local_stock.dart';
import 'package:app/model/reminders.dart';

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
                      intakeQuantity: reminderCard.intakeQuantity,
                      isTaken: reminderCard.isTaken,
                      isJumped: reminderCard.isJumped,
                      pressedTime: reminderCard.pressedTime,
                      //onMedicamentAction: onMedicamentAction,
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
  final int intakeQuantity;
  final bool isTaken;
  final bool isJumped;
  final TimeOfDay? pressedTime;

  const MedicationReminderCard({
    required this.cardId,
    required this.reminderId,
    required this.medicament,
    required this.day,
    required this.time,
    required this.intakeQuantity,
    required this.isTaken,
    required this.isJumped,
    this.pressedTime,
  });

  @override
  MedicationReminderCardState createState() => MedicationReminderCardState();
}

class MedicationReminderCardState extends State<MedicationReminderCard> {
  late bool isTaken;
  late bool isJumped;
  late TimeOfDay? pressedTime;
  late bool isTakeButton;

  @override
  void initState() {
    super.initState();
    isTaken = widget.isTaken;
    isJumped = widget.isJumped;
    pressedTime = widget.pressedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: GestureDetector(
          onTap: () {
            _showActionBottomSheet(context);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            color: isTaken || isJumped ? const Color.fromRGBO(255, 122, 0, 1) : const Color.fromRGBO(255, 218, 190, 1),
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
                          color: isTaken || isJumped ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
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
                                    color: isTaken || isJumped ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.time.format(context),
                                  style: TextStyle(
                                    fontFamily: 'Open_Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isTaken || isJumped ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
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
                                color: isTaken || isJumped ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
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
                          if (isJumped || isTaken) {
                            _showActionBottomSheet(context);
                          } else {
                            isTakeButton = true;
                            _takeMedicament(context);
                          }
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
                              : isJumped
                              ? 'Skipped'
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
      ),
    );
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: const Color.fromRGBO(225, 95, 0, 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        FontAwesomeIcons.solidClock,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.time.format(context),
                      style: const TextStyle(
                        fontFamily: 'Open_Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.medicament!.name,
                  style: const TextStyle(
                    fontFamily: 'Open_Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: isJumped
                      ? [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                _unSkipMedicamentIntake(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
                                elevation: 5,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.rotateLeft, color: Color.fromRGBO(255, 122, 0, 1)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Un-Skip',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(255, 122, 0, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
                      : [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                if (isTaken) {
                                  _changeIntakeTime(context);
                                } else {
                                  _skipMedicamentIntake(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
                                elevation: 5,
                              ),
                              child: Text(
                                isTaken ? 'Time' : 'Skip',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(255, 122, 0, 1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: () {
                                if (isTaken) {
                                  _unTakeMedicament(context);
                                } else {
                                  isTakeButton = false;
                                  _takeMedicament(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(255, 122, 0, 1),
                                elevation: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      isTaken ? FontAwesomeIcons.rotateLeft : FontAwesomeIcons.check,
                                      color: const Color.fromRGBO(255, 244, 236, 1)
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isTaken ? 'Un-Take' : 'Take',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(255, 244, 236, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _takeMedicament(BuildContext context) async {
    TimeOfDay now = TimeOfDay.now();

    int currentQuantity = await MedicamentStock().getMedicamentQuantity(widget.medicament!);

    int newQuantity = currentQuantity - widget.intakeQuantity;

    await MedicamentStock().changeMedicamentQuantity(widget.medicament!, newQuantity);

    final updatedCard = ReminderCard(
      cardId: widget.cardId,
      reminderId: widget.reminderId,
      day: widget.day,
      time: widget.time,
      intakeQuantity: widget.intakeQuantity,
      isTaken: true,
      isJumped: false,
      pressedTime: now,
    );

    await ReminderDatabase().updateReminderCard(updatedCard);

    setState(() {
      isTaken = true;
      isJumped = false;
      pressedTime = now;
    });

    if (!isTakeButton) Navigator.pop(context);
  }

  Future<void> _unTakeMedicament(BuildContext context) async {
    int currentQuantity = await MedicamentStock().getMedicamentQuantity(widget.medicament!);

    int newQuantity = currentQuantity + widget.intakeQuantity;

    await MedicamentStock().changeMedicamentQuantity(widget.medicament!, newQuantity);

    final updatedCard = ReminderCard(
      cardId: widget.cardId,
      reminderId: widget.reminderId,
      day: widget.day,
      time: widget.time,
      intakeQuantity: widget.intakeQuantity,
      isTaken: false,
      isJumped: false,
      pressedTime: null,
    );

    await ReminderDatabase().updateReminderCard(updatedCard);

    setState(() {
      isTaken = false;
      isJumped = false;
      pressedTime = null;
    });

    Navigator.pop(context);
  }

  Future<void> _skipMedicamentIntake(BuildContext context) async {
    final updatedCard = ReminderCard(
      cardId: widget.cardId,
      reminderId: widget.reminderId,
      day: widget.day,
      time: widget.time,
      intakeQuantity: widget.intakeQuantity,
      isTaken: false,
      isJumped: true,
      pressedTime: null,
    );

    await ReminderDatabase().updateReminderCard(updatedCard);

    setState(() {
      isJumped = true;
      isTaken = false;
      pressedTime = null;
    });

    Navigator.pop(context);
  }

  Future<void> _unSkipMedicamentIntake(BuildContext context) async {
    final updatedCard = ReminderCard(
      cardId: widget.cardId,
      reminderId: widget.reminderId,
      day: widget.day,
      time: widget.time,
      intakeQuantity: widget.intakeQuantity,
      isTaken: false,
      isJumped: false,
      pressedTime: null,
    );

    await ReminderDatabase().updateReminderCard(updatedCard);

    setState(() {
      isTaken = false;
      isJumped = false;
      pressedTime = null;
    });

    Navigator.pop(context);
  }

  Future<void> _changeIntakeTime(BuildContext context) async {
    TimeOfDay pickedTime = TimeOfDay.now();

    final TimeOfDay? newPickedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                children: [
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: DateTime(2024, 1, 1, pickedTime.hour, pickedTime.minute),
                      onDateTimeChanged: (DateTime newDateTime) {
                        setState(() {
                          pickedTime = TimeOfDay.fromDateTime(newDateTime);
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  CupertinoButton(
                    child: Text(
                      '${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Color.fromRGBO(243, 83, 0, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, pickedTime);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (newPickedTime != null) {
      final updatedCard = ReminderCard(
        cardId: widget.cardId,
        reminderId: widget.reminderId,
        day: widget.day,
        time: widget.time,
        intakeQuantity: widget.intakeQuantity,
        isTaken: widget.isTaken,
        isJumped: widget.isJumped,
        pressedTime: newPickedTime,
      );

      await ReminderDatabase().updateReminderCard(updatedCard);

      setState(() {
        isTaken = widget.isTaken;
        isJumped = widget.isJumped;
        pressedTime = newPickedTime;
      });

      Navigator.pop(context);
    }
  }
}
