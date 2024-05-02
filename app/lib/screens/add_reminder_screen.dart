import 'package:app/medicaments.dart';
import 'package:app/reminders.dart';
import 'package:app/screens/stock_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class AddReminderPage extends StatefulWidget {
  Future<List<Medicament>> medicamentList;
  final VoidCallback onReminderSaved;
  final VoidCallback onMedicamentListUpdated;

  AddReminderPage({Key? key, required this.onReminderSaved, required this.medicamentList, required this.onMedicamentListUpdated}) : super(key: key);

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
          color: _isSelected ? const Color.fromRGBO(243, 83, 0, 1) : Colors.grey[300],
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
  final ReminderDatabase _reminderDatabase = ReminderDatabase();

  String _reminderName = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  List<TimeOfDay> _times = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 19, minute: 0),
  ]; // Default time
  Medicament? _medicament;
  bool _everyDay = true;
  List<bool> _selectedDays = [false, false, false, false, false, false, false];
  int _intakeQuantity = 1;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(DateTime.now().year, 1, 1),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromRGBO(243, 83, 0, 1),
            colorScheme: const ColorScheme.light(primary: Color.fromRGBO(243, 83, 0, 1),),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime minEndDate = _startDate.add(const Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: minEndDate,
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromRGBO(243, 83, 0, 1),
            colorScheme: const ColorScheme.light(primary: Color.fromRGBO(243, 83, 0, 1),),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, [TimeOfDay? initialTime]) async {
    TimeOfDay pickedTime = initialTime ?? const TimeOfDay(hour: 8, minute: 0);

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
      final newTime = newPickedTime;
      if (!_times.any((time) => time.hour == newTime.hour && time.minute == newTime.minute)) {
        setState(() {
          if (initialTime != null) {
            // If editing an existing time, remove the old time first
            _times.removeWhere((time) => time.hour == initialTime.hour && time.minute == initialTime.minute);
          }
          _times.add(newTime);
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
                      const SizedBox(height: 16.0),
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          'End Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromRGBO(171, 58, 0, 1),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectEndDate(context),
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
                                DateFormat('MMMM d, y').format(_endDate),
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
                          'Medicament',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromRGBO(171, 58, 0, 1),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => StockScreen(selectionMode: true, medicamentList: widget.medicamentList, onMedicamentListUpdated: widget.onMedicamentListUpdated,))).then((selectedMedicament) {
                            setState(() {
                              _medicament = selectedMedicament;
                            });
                          })
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
                                FontAwesomeIcons.pills,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _medicament != null ? _medicament!.name : 'Select medicament',
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
                          'Intake Quantity',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color.fromRGBO(171, 58, 0, 1),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(225, 95, 0, 1),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_intakeQuantity > 1) _intakeQuantity --;
                                });
                              },
                            ),
                            Text(
                              '$_intakeQuantity',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _intakeQuantity ++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
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
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectTime(context, time),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10.0),
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  Positioned(
                    top: 22,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        _saveReminder();
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Color.fromRGBO(215, 74, 0, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _saveReminder() async{
    if (_everyDay) {
      setState(() {
        _selectedDays = List.generate(7, (index) => true);
      });
    }
    if (_times.isEmpty || _medicament == null) {
      String? message;
      if (_times.isEmpty && _medicament == null) {
        message = 'Please select a medicament and at least one time for the reminder';
      } else if (_times.isEmpty) {
        message = 'Please select at least one time for the reminder';
      } else if (_medicament == null) {
        message = 'Please select a medicament for the reminder';
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('ERROR'),
              content: Text(message!),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Color.fromRGBO(215, 74, 0, 1),
                    ),
                  ),
                ),
              ],
            );
          }
      );
      return;
    }
    try {
      int reminderId = DateTime.now().millisecondsSinceEpoch;
      Reminder newReminder = Reminder(
          id: reminderId,
          reminderName: _reminderName,
          selectedDays: _selectedDays,
          startDate: _startDate,
          endDate: _endDate,
          medicament: _medicament!.id,
          intakeQuantity: _intakeQuantity,
          times: _times,
      );

      int result = await _reminderDatabase.insertReminder(newReminder);
      if (result != -1) {
        print('Reminder added successfully');
        print('Reminder Details:');
        print('ID: ${newReminder.id}');
        print('Name: ${newReminder.reminderName}');
        print('Selected Days: ${newReminder.selectedDays}');
        print('Start Date: ${newReminder.startDate}');
        print('End Date: ${newReminder.endDate}');
        print('Medicament: ${newReminder.medicament}');
        print('Times: ${newReminder.times}');
        saveReminderCards(reminderId);
        widget.onReminderSaved();
        Navigator.pop(context);
      } else {
        print('Failed to add reminder');
      }
    } catch (e) {
      print('Error saving reminder: $e');
    }
  }

  void saveReminderCards(int reminderId) async {
    try {
      for (DateTime date = _startDate; date.isBefore(_endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        for (TimeOfDay time in _times) {
          final cardId = '${reminderId}_${date.day}_${date.month}_${date.year}_${time.hour}_${time.minute}';
          ReminderCard reminderCard = ReminderCard(
            cardId: cardId,
            reminderId: reminderId,
            day: date,
            time: time,
            intakeQuantity: _intakeQuantity,
            isTaken: false,
            isJumped: false,
          );

          String result = await _reminderDatabase.insertReminderCard(reminderCard);
          if (result != '-1') {
            print('ReminderCard added successfully');
            print('ReminderCard Details:');
            print('CardID (Type: ${cardId.runtimeType}): $cardId');
            print('ReminderID (Type: ${reminderId.runtimeType}): $reminderId');
            print('Day (Type: ${date.runtimeType}): $date');
            print('Time (Type: ${time.runtimeType}): $time');
          } else {
            print('Failed to add reminderCard');
          }
        }
      }
    } catch (e) {
      print('Error saving reminderCard: $e');
    }
  }

  void _showFrequencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 70,
              child: ListTile(
                title: const Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Text(
                    'Daily',
                    style: TextStyle(
                       fontSize: 20,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _everyDay = true;
                    _selectedDays = [false, false, false, false, false, false, false];
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(
              height: 70,
              child: ListTile(
                title: const Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Text(
                    'Specific Days',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                onTap: () {
                  _everyDay = false;
                  _showDaysOfWeekBottomSheet(context);
                },
              ),
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
                TextButton(
                  onPressed: () {
                    if (_selectedDays.every((day) => !day)) {
                      setState(() {
                        _everyDay = true;
                      });
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
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
                            _everyDay = false;
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
    if (selectedDays.isEmpty) {
      _everyDay = true;
      return 'Remind me everyday';
    } else {
      return selectedDays.join(', ');
    }
  }
}
