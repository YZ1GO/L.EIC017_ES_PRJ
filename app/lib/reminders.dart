import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Reminder {
  final int id;
  String reminderName;
  List<bool> selectedDays;
  DateTime startDate;
  DateTime endDate;
  int medicament;
  List<TimeOfDay> times;

  Reminder({
    required this.id,
    required this.reminderName,
    required this.selectedDays,
    required this.startDate,
    required this.endDate,
    required this.medicament,
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
  final bool isTaken;
  final bool isJumped;

  ReminderCard({
    required this.cardId,
    required this.reminderId,
    required this.day,
    required this.time,
    required this.isTaken,
    required this.isJumped,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'reminderId': reminderId,
      'day': day.millisecondsSinceEpoch,
      'time': time.hour * 60 + time.minute,
      'isTaken': isTaken ? 1 : 0,
      'isJumped': isJumped ? 1 : 0,
    };
  }

  factory ReminderCard.fromMap(Map<String, dynamic> map) {
    return ReminderCard(
      cardId: map['cardId'],
      reminderId: map['reminderId'],
      day: DateTime.fromMillisecondsSinceEpoch(map['day']),
      time: TimeOfDay(hour: map['time'] ~/ 60, minute: map['time'] % 60),
      isTaken: map['isTaken'] == 1,
      isJumped: map['isJumped'] == 1,
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
      version: 2,
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
            isTaken INTEGER,
            isJumped INTEGER,
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
      print('Inserted reminder ${reminder.reminderName}');
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
      print('Getting reminders list');
      return List.generate(maps.length, (i) {
        return Reminder.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching reminders: $e');
      return [];
    }
  }

  Future<void> clearReminders() async {
    try {
      await _database.delete('reminders');
      print('Cleared all reminders from the database');
      await _database.delete('reminder_cards');
      print('Cleared all reminder cards from the database');
    } catch (e) {
      print('Error clearing reminders: $e');
    }
  }

  Future<int> deleteReminder(int id) async {
    try {
      int rowsDeleted = await _database.delete(
        'reminders',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsDeleted > 0) {
        print('Deleted reminder with ID: $id');
      } else {
        print('No reminder found with ID: $id');
      }

      return rowsDeleted;
    } catch (e) {
      print('Error deleting reminder: $e');
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
        print('Inserted reminder card ${card.cardId}');
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
      print('Updated reminder card $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Error updating reminder card: $e');
      return -1;
    }
  }

  Future<List<ReminderCard>> getReminderCards(int reminderId, DateTime selectedDay) async {
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

}