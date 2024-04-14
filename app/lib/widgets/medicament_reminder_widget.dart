import 'package:flutter/material.dart';

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
        SizedBox(height: 10),
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

class MedicationReminderCard extends StatelessWidget {
  final String medicamentName;
  final TimeOfDay time;
  final VoidCallback onPressed;

  const MedicationReminderCard({
    required this.medicamentName,
    required this.time,
    required this.onPressed,
  });

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
          color: const Color.fromRGBO(255, 218, 190, 1),
          child: SizedBox(
            height: 150,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.access_time,
                              color: Color.fromRGBO(225, 95, 0, 1),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            formatTimeToString(time),
                            style: const TextStyle(
                              fontFamily: 'Open_Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color.fromRGBO(225, 95, 0, 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                          medicamentName,
                        style: const TextStyle(
                          fontFamily: 'Open_Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color.fromRGBO(225, 95, 0, 1),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onPressed,
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
                      child: const Text(
                          'Take',
                          style: TextStyle(
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

  String formatTimeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}




