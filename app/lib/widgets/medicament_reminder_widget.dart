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
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  formatTimeToString(time),
                ),
                const SizedBox(height: 10),
                Text(medicamentName),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text('TAKE'),
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

