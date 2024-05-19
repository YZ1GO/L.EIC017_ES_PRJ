import 'package:flutter/material.dart';

import '../database/local_stock.dart';
import '../model/medicaments.dart';
import '../model/reminders.dart';

class ManageRemindersScreen extends StatefulWidget {
  const ManageRemindersScreen({Key? key}) : super(key: key);

  @override
  _ManageRemindersScreenState createState() => _ManageRemindersScreenState();
}

class _ManageRemindersScreenState extends State<ManageRemindersScreen> {
  List<Reminder> reminders = [];
  List<Medicament> medicaments = [];

  @override
  void initState() {
    super.initState();
    fetchReminders();
    fetchMedicaments();
  }

  fetchReminders() async {
    reminders = await ReminderDatabase().getReminders();
    setState(() {});
  }

  fetchMedicaments() async {
    medicaments = await MedicamentStock().getMedicaments();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 235, 1),
      appBar: AppBar(
        title: const Text('Manage Reminders'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(reminders[index].reminderName),
              subtitle: Text('Something'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to the edit reminder page
                      // Pass the reminder to the edit page
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Delete the reminder
                      setState(() {
                        reminders.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}