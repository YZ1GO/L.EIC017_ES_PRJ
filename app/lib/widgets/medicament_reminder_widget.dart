import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MedicationReminderWidget extends StatelessWidget {
  final String medicamentName;
  final DateTime dayAdded;
  final List<TimeOfDay> frequencies;

  const MedicationReminderWidget({super.key,
    required this.medicamentName,
    required this.dayAdded,
    required this.frequencies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Column(
          children: frequencies.map((time) {
            return MedicationReminderCard(
              medicamentName: medicamentName,
              time: time,
              onPressed: () {

              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MedicationReminderCard extends StatefulWidget {
  final String medicamentName;
  final TimeOfDay time;
  final VoidCallback onPressed;

  const MedicationReminderCard({
    required this.medicamentName,
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
          color: isTaken ? const Color.fromRGBO(255, 122, 0, 1) : const Color.fromRGBO(255, 218, 190, 1),
          child: SizedBox(
            height: 150,
            child: Stack(
              children: [
                // Specifics of medication
                Stack(
                  children: [
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
                                  Icons.access_time,
                                  color: isTaken ? Colors.white : const Color.fromRGBO(225, 95, 0, 1),
                                ),
                              ),
                              const SizedBox(width: 2),
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
                            widget.medicamentName,
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
