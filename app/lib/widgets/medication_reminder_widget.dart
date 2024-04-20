import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../medicaments.dart';

class MedicationReminderWidget extends StatelessWidget {
  final String reminderName;
  final List<bool> selectedDays;
  final DateTime startDay;
  final Medicament? medicament;
  final List<TimeOfDay> times;

  const MedicationReminderWidget({super.key,
    required this.reminderName,
    required this.selectedDays,
    required this.startDay,
    required this.medicament,
    required this.times,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: times.map((time) {
        return MedicationReminderCard(
          medicament: medicament,
          time: time,
          onPressed: () {
            },
        );
      }).toList(),
    );
  }
}

class MedicationReminderCard extends StatefulWidget {
  final Medicament? medicament;
  final TimeOfDay time;
  final VoidCallback onPressed;

  const MedicationReminderCard({
    required this.medicament,
    required this.time,
    required this.onPressed,
  });

  @override
  MedicationReminderCardState createState() => MedicationReminderCardState();
}

class MedicationReminderCardState extends State<MedicationReminderCard> {
  late TimeOfDay? pressedTime;
  bool isTaken = false;

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
                      onPressed: () {
                        setState(() {
                          if (isTaken) {
                            isTaken = false;
                            pressedTime = null;
                          } else {
                            isTaken = true;
                            pressedTime = TimeOfDay.now();
                          }
                        });
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
