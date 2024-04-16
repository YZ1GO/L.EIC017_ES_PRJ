import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AddReminderPage extends StatefulWidget {
  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class DaySelectionCircle extends StatefulWidget {
  final bool isSelected;
  final int index;
  final List<bool> selectedDays;
  final Function(bool) onChanged;

  DaySelectionCircle({
    required this.isSelected,
    required this.index,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  _DaySelectionCircleState createState() => _DaySelectionCircleState();

  static String _getDayName(int index) {
    switch (index) {
      case 0:
        return 'Sun';
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      default:
        return '';
    }
  }
}

class _DaySelectionCircleState extends State<DaySelectionCircle> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!_isSelected && widget.selectedDays.where((day) => day).length >= 6) {
          return;
        }
        setState(() {
          _isSelected = !_isSelected;
        });
        widget.onChanged(_isSelected);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isSelected ? const Color.fromRGBO(171, 58, 0, 1) : Colors.grey[300],
        ),
        child: Center(
          child: Text(
            DaySelectionCircle._getDayName(widget.index),
            style: TextStyle(
              color: _isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddReminderPageState extends State<AddReminderPage> {
  String _reminderName = '';
  DateTime _startDate = DateTime.now();
  List<TimeOfDay> _times = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 19, minute: 0),
  ]; // Default time
  bool _everyDay = true;
  List<bool> _selectedDays = [false, false, false, false, false, false, false];

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
      final newTime = picked;
      if (!_times.any((time) => time.hour == newTime.hour && time.minute == newTime.minute)) {
        setState(() {
          _times.add(picked);
          _times.sort((a, b) => _timeOfDayToInt(a).compareTo(_timeOfDayToInt(b)));
        });
      }
    }
  }

  int _timeOfDayToInt(TimeOfDay time) => time.hour * 60 + time.minute;

  void _removeTime(int index) {
    setState(() {
      _times.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 235, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                      const SizedBox(height: 22.0),
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          'Frequency',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromRGBO(171, 58, 0, 1),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showFrequencyBottomSheet(context);
                        },
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
                                FontAwesomeIcons.penToSquare,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _everyDay ? 'Remind me everyday' : _getSelectedDaysText(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          'Start Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromRGBO(171, 58, 0, 1),
                          ),
                        ),
                      ),
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
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          'Time',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromRGBO(171, 58, 0, 1),
                          ),
                        ),
                      ),
                      Column(
                        children: _times
                            .asMap()
                            .map((index, time) => MapEntry(
                          index,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 10.0),
                                width: MediaQuery.of(context).size.width * 0.8,
                                padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(225, 95, 0, 1),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text(
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              GestureDetector(
                                onTap: () => _removeTime(index),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10.0),
                                  width: MediaQuery.of(context).size.width * 0.1,
                                  padding: const EdgeInsets.symmetric(vertical: 13.0),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 178, 65, 1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                            .values
                            .toList(),
                      ),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 45,
                        child: FloatingActionButton(
                          onPressed: () {
                            _selectTime(context);
                          },
                          backgroundColor: const Color.fromRGBO(255, 195, 150, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Color.fromRGBO(215, 74, 0, 1)),
                              Text(
                                'Add',
                                style: TextStyle(
                                  color: Color.fromRGBO(215, 74, 0, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
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
                        padding: const EdgeInsets.all(15.0),
                        child: const Icon(
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
                    child: Image.asset(
                      'assets/icons/pingu-transparent-shadow.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: const Color.fromRGBO(215, 74, 0, 1),
            width: double.infinity, // Occupies the whole width of the screen
            child: GestureDetector(
              onTap: () {
                _saveReminder();
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveReminder() {
    // Implement saving reminder logic here
    // For now, you can print reminder details
    print('Reminder Name: $_reminderName');
    print('Start Date: $_startDate');
    print('Times: $_times');
    print('Frequency: ${_everyDay ? 'Everyday' : 'Select days of week'}');
  }

  void _showFrequencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Remind me everyday'),
              onTap: () {
                setState(() {
                  _everyDay = true;
                  _selectedDays = [false, false, false, false, false, false, false];
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Select days of week'),
              onTap: () {
                _everyDay = false;
                _showDaysOfWeekBottomSheet(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDaysOfWeekBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Close current modal sheet
                  },
                  icon: Icon(Icons.arrow_back), // Back button
                ),
                TextButton( // Changed from ElevatedButton to TextButton
                  onPressed: () {
                    Navigator.pop(context); // Close current modal sheet
                  },
                  child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  7,
                      (index) => DaySelectionCircle(
                    isSelected: _selectedDays[index],
                    index: index,
                        selectedDays: _selectedDays,
                        onChanged: (isSelected) {
                          if (isSelected && _selectedDays.where((day) => day).length >= 6) {
                            return;
                          }
                          setState(() {
                            _selectedDays[index] = isSelected;
                          });
                        },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getSelectedDaysText() {
    List<String> selectedDays = [];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        selectedDays.add(DaySelectionCircle._getDayName(i));
      }
    }
    return selectedDays.isEmpty ? 'Select days of week' : selectedDays.join(', ');
  }
}
