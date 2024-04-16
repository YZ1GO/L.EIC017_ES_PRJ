import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AddReminderPage extends StatefulWidget {
  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  String _reminderName = '';
  DateTime _startDate = DateTime.now();
  List<TimeOfDay> _times = [TimeOfDay(hour: 8, minute: 0)]; // Default time

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(DateTime.now().year, 1, 1), // Set the first date to January 1st of the current year
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _times.add(picked);
      });
    }
  }

  void _removeTime(int index) {
    setState(() {
      _times.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 235, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 120),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 195, 150, 1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _reminderName = value;
                      });
                    },
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Enter reminder name',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Start Date',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color.fromRGBO(171, 58, 0, 1),
                  ),
                ),
                SizedBox(height: 6.0),
                GestureDetector(
                  onTap: () => _selectStartDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(225, 95, 0, 1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.calendarCheck,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('MMMM d, y').format(_startDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                const Text(
                  'Times',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color.fromRGBO(171, 58, 0, 1),
                  ),
                ),
                SizedBox(height: 6.0),
                Column(
                  children: _times
                      .asMap()
                      .map((index, time) => MapEntry(
                    index,
                    GestureDetector(
                      onTap: () => _removeTime(index),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(225, 95, 0, 1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${time.hour}:${time.minute}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
                      .values
                      .toList(),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle saving reminder here
                      _saveReminder();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              left: -15,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the page
                },
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 28.0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 17,
              left: (MediaQuery.of(context).size.width - 150) / 2,
              child: GestureDetector(
                onTap: () {}, // Add any onTap logic if needed
                child: Image.asset(
                  'assets/icons/pingu-transparent-shadow.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveReminder() {
    // Implement saving reminder logic here
    // For now, you can print reminder details
    print('Reminder Name: $_reminderName');
    print('Start Date: $_startDate');
    print('Times: $_times');
  }
}
