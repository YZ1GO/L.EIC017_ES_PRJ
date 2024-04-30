import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app/reminders.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {
  sqfliteFfiInit();
  late ReminderDatabase reminderDatabase;

  group('Reminders', () {
    setUp(() async {
      databaseFactory = databaseFactoryFfi;
      reminderDatabase = ReminderDatabase();
      await reminderDatabase.initDatabase();
    });

    tearDown(() async {
      await reminderDatabase.clearReminders();
    });

    test('Insert and retrieve reminder', () async {
      final reminder = Reminder(
        id: 1,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        medicament: 55555555555,
        times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 12, minute: 0)],
      );

      final insertedId = await reminderDatabase.insertReminder(reminder);
      expect(insertedId, 1);

      final retrievedReminder = await reminderDatabase.getReminderById(1);
      expect(retrievedReminder?.id, 1);
      expect(retrievedReminder?.reminderName, 'Test Reminder');
      expect(retrievedReminder?.selectedDays, [true, false, true, false, true, false, true]);
      expect(retrievedReminder?.medicament, 55555555555);
    });

    test('Insert and delete reminder', () async {
      final reminder = Reminder(
        id: 1,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        medicament: 1,
        times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 12, minute: 0)],
      );

      final insertedId = await reminderDatabase.insertReminder(reminder);
      expect(insertedId, 1);

      final rowsDeleted = await reminderDatabase.deleteReminder(1);
      expect(rowsDeleted, 1);

      final retrievedReminder = await reminderDatabase.getReminderById(1);
      expect(retrievedReminder, null); // Make sure the reminder is deleted
    });

    test('Insert and retrieve reminder card', () async {
      final reminderCard = ReminderCard(
        cardId: '11713990594727480',
        reminderId: 1,
        day: DateTime.now(),
        time: TimeOfDay(hour: 8, minute: 0),
        isTaken: false,
        isJumped: false,
      );

      final insertedId = await reminderDatabase.insertReminderCard(reminderCard);
      expect(insertedId, '11713990594727480');

      final retrievedCards = await reminderDatabase.getReminderCards(1);
      expect(retrievedCards.length, 1);
      expect(retrievedCards[0].cardId, '11713990594727480');
      expect(retrievedCards[0].reminderId, 1);
    });
  });
}
