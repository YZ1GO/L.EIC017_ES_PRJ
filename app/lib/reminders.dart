import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Reminder {
  final int id;
  String reminderName;
  List<bool> selectedDays;
  DateTime startDate;
  String medicament;
  List<TimeOfDay> times;

  Reminder({
    required this.id,
    required this.reminderName,
    required this.selectedDays,
    required this.startDate,
    required this.medicament,
    required this.times,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderName': reminderName,
      'selectedDays': selectedDays.join(','),
      'startDate': startDate.millisecondsSinceEpoch,
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
      medicament: map['medicament'],
      times: (map['times'] as String)
          .split(',')
          .map((e) => TimeOfDay(hour: int.parse(e) ~/ 60, minute: int.parse(e) % 60))
          .toList(),
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
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''
          CREATE TABLE reminders(
            id INTEGER PRIMARY KEY,
            reminderName TEXT,
            selectedDays TEXT,
            startDate INTEGER,
            medicament TEXT,
            times TEXT
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
    try {
      final List<Map<String, dynamic>> maps = await _database.query('reminders');
      print('Getting reminders list');
      return List.generate(maps.length, (i) {
        return Reminder.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching reminders: $e');
      return [];
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
}