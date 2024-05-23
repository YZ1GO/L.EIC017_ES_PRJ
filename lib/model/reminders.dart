import 'dart:async';
import 'package:app/database/local_medicament_stock.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../notifications/system_notification.dart';
import 'medicaments.dart';

class Reminder {
  final int id;
  String reminderName;
  List<bool> selectedDays;
  DateTime startDate;
  DateTime endDate;
  int medicament;
  int intakeQuantity;
  List<TimeOfDay> times;

  Reminder({
    required this.id,
    required this.reminderName,
    required this.selectedDays,
    required this.startDate,
    required this.endDate,
    required this.medicament,
    required this.intakeQuantity,
    required this.times,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderName': reminderName,
      'selectedDays': selectedDays.join(','),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'medicament': medicament,
      'intakeQuantity': intakeQuantity,
      'times': times.map((time) => time.hour * 60 + time.minute).toList().join(','), // Convert list to string
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      reminderName: map['reminderName'],
      selectedDays: (map['selectedDays'] as String).split(',').map((e) => e == 'true').toList(),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      medicament: map['medicament'],
      intakeQuantity: map['intakeQuantity'],
      times: (map['times'] as String)
          .split(',')
          .map((e) => TimeOfDay(hour: int.parse(e) ~/ 60, minute: int.parse(e) % 60))
          .toList(),
    );
  }
}

class ReminderCard {
  final String cardId; // composed by reminderId + day + time
  final int reminderId;
  final DateTime day;
  final TimeOfDay time;
  final int intakeQuantity;
  final bool isTaken;
  final bool isJumped;
  final TimeOfDay? pressedTime;

  ReminderCard({
    required this.cardId,
    required this.reminderId,
    required this.day,
    required this.time,
    required this.intakeQuantity,
    required this.isTaken,
    required this.isJumped,
    this.pressedTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'reminderId': reminderId,
      'day': day.millisecondsSinceEpoch,
      'time': time.hour * 60 + time.minute,
      'intakeQuantity': intakeQuantity,
      'isTaken': isTaken ? 1 : 0,
      'isJumped': isJumped ? 1 : 0,
      'pressedTime': pressedTime != null ? pressedTime!.hour * 60 + pressedTime!.minute : null,
    };
  }

  factory ReminderCard.fromMap(Map<String, dynamic> map) {
    return ReminderCard(
      cardId: map['cardId'],
      reminderId: map['reminderId'],
      day: DateTime.fromMillisecondsSinceEpoch(map['day']),
      time: TimeOfDay(hour: map['time'] ~/ 60, minute: map['time'] % 60),
      intakeQuantity: map['intakeQuantity'],
      isTaken: map['isTaken'] == 1,
      isJumped: map['isJumped'] == 1,
      pressedTime: map['pressedTime'] != null ? TimeOfDay(hour: map['pressedTime'] ~/ 60, minute: map['pressedTime'] % 60) : null,
    );
  }
}

class ReminderDatabase {
  static final ReminderDatabase _instance = ReminderDatabase._internal();
  late Database _database;

  factory ReminderDatabase() => _instance;

  ReminderDatabase._internal();

  Future<void> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final String path = join(await getDatabasesPath(), 'reminders_database.db');
    _database = await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''
          CREATE TABLE reminders(
            id INTEGER PRIMARY KEY,
            reminderName TEXT,
            selectedDays TEXT,
            startDate INTEGER,
            endDate INTEGER,
            medicament INTEGER,
            intakeQuantity INTEGER,
            times TEXT
          )
          ''',
        );

        await db.execute(
          '''
          CREATE TABLE reminder_cards(
            cardId TEXT PRIMARY KEY,
            reminderId INTEGER,
            day INTEGER,
            time INTEGER,
            intakeQuantity INTEGER,
            isTaken INTEGER,
            isJumped INTEGER,
            pressedTime INTEGER,
          FOREIGN KEY (reminderId) REFERENCES reminders(id)
          )
          ''',
        );
      },
    );
  }

  Future<int> insertReminder(Reminder reminder) async {
    try {
      final int id = await _database.insert('reminders', reminder.toMap());
      return id;
    } catch (e) {
      print('Error inserting reminder: $e');
      return -1;
    }
  }

  Future<Reminder?> getReminderById(int id) async {
    try {
      List<Map<String, dynamic>> maps = await _database.query(
        'reminders',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Reminder.fromMap(maps.first);
      } else {
        print('Reminder not found with ID: $id');
        return null;
      }
    } catch (e) {
      print('Error fetching reminder: $e');
      return null;
    }
  }

  Future<List<Reminder>> getReminders() async {
    List<Map<String, dynamic>> maps = [];
    try {
      maps = await _database.query('reminders');
      return List.generate(maps.length, (i) {
        return Reminder.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching reminders: $e');
      return [];
    }
  }

  Future<void> clearAllReminders() async {
    try {
      await _database.delete('reminders');
      await _database.delete('reminder_cards');
    } catch (e) {
      print('Error clearing reminders: $e');
    }
  }

  Future<int> deleteReminderByReminderId(int reminderId) async {
    try {
      cancelReminderCardsTimers(reminderId);

      await deleteReminderCardsByReminderId(reminderId);

      int rowsDeleted = await _database.delete(
        'reminders',
        where: 'id = ?',
        whereArgs: [reminderId],
      );

      if (rowsDeleted <= 0) {
        print('No reminder found with ID: $reminderId');
      }

      return rowsDeleted;
    } catch (e) {
      print('Error deleting reminder: $e');
      return -1;
    }
  }

  Future<int> deleteReminderByMedicamentId(int medicamentId) async {
    try {
      List<Map<String, dynamic>> reminders = await _database.query(
        'reminders',
        where: 'medicament = ?',
        whereArgs: [medicamentId],
      );

      for (var reminder in reminders) {
        await deleteReminderCardsByReminderId(reminder['id']);
      }

      int rowsDeleted = await _database.delete(
        'reminders',
        where: 'medicament = ?',
        whereArgs: [medicamentId],
      );

      if (rowsDeleted <= 0) {
        print('No reminder found with medicament ID: $medicamentId');
      }

      return rowsDeleted;
    } catch (e) {
      print('Error deleting reminder: $e');
      return -1;
    }
  }

  Future<int> updateReminder(Reminder reminder) async {
    try {
      Map<String, dynamic> reminderMap = reminder.toMap();
      reminderMap.remove('startDate');
      reminderMap.remove('reminderId');
      reminderMap.remove('medicament');

      final int rowsAffected = await _database.update(
        'reminders',
        reminderMap,
        where: 'id = ?',
        whereArgs: [reminder.id],
      );

      await updateReminderCards(reminder);

      return rowsAffected;
    } catch (e) {
      print('Error updating reminder: $e');
      return -1;
    }
  }

  /***************************REMINDER CARD***************************/

  Future<String> insertReminderCard(ReminderCard card) async {
    try {
      final existingCard = await _database.query(
        'reminder_cards',
        where: 'cardId = ?',
        whereArgs: [card.cardId],
      );

      if (existingCard.isEmpty) {
        await _database.insert('reminder_cards', card.toMap());
        return card.cardId;
      } else {
        print('Reminder card with the same ID already exists');
        return '-1';
      }
    } catch (e) {
      print('Error inserting reminder card: $e');
      return '-1';
    }
  }

  Future<int> updateReminderCard(ReminderCard card) async {
    try {
      final int rowsAffected = await _database.update(
        'reminder_cards',
        card.toMap(),
        where: 'cardId = ?',
        whereArgs: [card.cardId],
      );
      return rowsAffected;
    } catch (e) {
      print('Error updating reminder card: $e');
      return -1;
    }
  }

  Future<List<ReminderCard>> getReminderCardsByReminderId(int reminderId) async {
    List<Map<String, dynamic>> maps = [];
    try {
      maps = await _database.query(
        'reminder_cards',
        where: 'reminderId = ?',
        whereArgs: [reminderId],
      );
      return List.generate(maps.length, (i) {
        return ReminderCard.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching reminder cards: $e');
      return [];
    }
  }

  Future<List<ReminderCard>> getReminderCardsForSelectedDay(int reminderId, DateTime selectedDay) async {
    List<Map<String, dynamic>> maps = [];
    try {
      final year = selectedDay.year;
      final month = selectedDay.month;
      final day = selectedDay.day;

      // Convert DateTime to include only the date part without the time
      final startOfDay = DateTime(year, month, day).millisecondsSinceEpoch;
      final endOfDay = DateTime(year, month, day, 23, 59, 59).millisecondsSinceEpoch;

      maps = await _database.query(
        'reminder_cards',
        where: 'reminderId = ? AND day BETWEEN ? AND ?',
        whereArgs: [reminderId, startOfDay, endOfDay],
      );
      return List.generate(maps.length, (i) {
        return ReminderCard.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching reminder cards: $e');
      return [];
    }
  }

  Future<int> deleteReminderCardsByReminderId(int reminderId) async {
    try {
      int rowsDeleted = await _database.delete(
        'reminder_cards',
        where: 'reminderId = ?',
        whereArgs: [reminderId],
      );

      if (rowsDeleted <= 0) {
        print('No reminder cards found with reminder ID: $reminderId');
      }

      return rowsDeleted;
    } catch (e) {
      print('Error deleting reminder cards: $e');
      return -1;
    }
  }

  Future<void> updateReminderCards(Reminder reminder) async {
    try {
      // Fetch all the reminder cards associated with this reminder
      List<Map<String, dynamic>> maps = await _database.query(
        'reminder_cards',
        where: 'reminderId = ?',
        whereArgs: [reminder.id],
      );

      // Filter out the reminder cards that are scheduled for tomorrow or future dates
      List<ReminderCard> futureReminderCards = maps.map((map) => ReminderCard.fromMap(map)).where((card) => card.day.isAfter(DateTime.now())).toList();

      // Delete these future reminder cards from the database
      for (ReminderCard card in futureReminderCards) {
        cancelTimer(card.cardId);
        await _database.delete(
          'reminder_cards',
          where: 'cardId = ?',
          whereArgs: [card.cardId],
        );
      }

      DateTime tomorrowMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 1));

      // Insert the new reminder cards into the database
      for (DateTime date = tomorrowMidnight; date.isBefore(reminder.endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        if (!reminder.selectedDays[date.weekday % 7]) {
          continue; // Skip this iteration if the day is not selected
        }
        for (TimeOfDay time in reminder.times) {
          final cardId = '${reminder.id}_${date.day}_${date.month}_${date.year}_${time.hour}_${time.minute}';
          ReminderCard newCard = ReminderCard(
            cardId: cardId,
            reminderId: reminder.id,
            day: date,
            time: time,
            intakeQuantity: reminder.intakeQuantity,
            isTaken: false,
            isJumped: false,
          );
          await _database.insert('reminder_cards', newCard.toMap());

          DateTime scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);

          Medicament? medicament = await MedicamentStock().getMedicamentById(reminder.medicament);

          scheduleNotification(cardId, medicament!.name, reminder.reminderName, scheduledDate);
        }
      }
    } catch (e) {
      print('Error updating reminder cards: $e');
    }
  }
}