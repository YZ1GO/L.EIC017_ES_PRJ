import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app/model/reminders.dart';

void main() {
  sqfliteFfiInit();

  group('ReminderDatabase', () {
    late ReminderDatabase reminderDatabase;
    int myReminderId = 99900099900;  //to avoid conflict with already existing content

    setUp(() async {
      databaseFactory = databaseFactoryFfi;
      reminderDatabase = ReminderDatabase();
      await reminderDatabase.initDatabase();
      await reminderDatabase.deleteReminderByReminderId(myReminderId); //delete at the beginning to avoid conflict
    });

    test('Insert and remove reminder', () async {
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 2,
        times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)],
      );

      final insertedId = await reminderDatabase.insertReminder(reminder);
      expect(insertedId, myReminderId);

      final rowsDeleted = await reminderDatabase.deleteReminderByReminderId(myReminderId);
      expect(rowsDeleted, 1);
    });

    test('Insert and retrieve reminder', () async {
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 2,
        times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)],
      );

      final insertedId = await reminderDatabase.insertReminder(reminder);
      expect(insertedId, myReminderId);

      final retrievedReminder = await reminderDatabase.getReminderById(myReminderId);
      expect(retrievedReminder?.id, myReminderId);
      expect(retrievedReminder?.reminderName, 'Test Reminder');
      expect(retrievedReminder?.medicament, 123);
    });

    test('Insert and update reminder', () async {
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 2,
        times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)],
      );

      await reminderDatabase.insertReminder(reminder);

      final updatedReminder = Reminder(
        id: myReminderId,
        reminderName: 'Updated Test Reminder',
        selectedDays: [false, true, false, true, false, true, false],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 8)),
        medicament: 123,
        intakeQuantity: 3,
        times: [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 21, minute: 0)],
      );

      await reminderDatabase.updateReminder(updatedReminder);

      final retrievedReminder = await reminderDatabase.getReminderById(myReminderId);
      expect(retrievedReminder?.reminderName, 'Updated Test Reminder');
      expect(retrievedReminder?.medicament, 123);
      expect(retrievedReminder?.intakeQuantity, 3);
    });

    test('Get all reminders', () async {
      // Insert a reminder
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 1,
        times: [TimeOfDay(hour: 8, minute: 0)],
      );
      await reminderDatabase.insertReminder(reminder);

      // Now get all reminders
      final reminders = await reminderDatabase.getReminders();
      expect(reminders, isNotEmpty);
    });

    test('Clear all reminders', () async {
      // Insert a reminder
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 1,
        times: [TimeOfDay(hour: 8, minute: 0)],
      );
      await reminderDatabase.insertReminder(reminder);

      // Now clear all reminders
      await reminderDatabase.clearAllReminders();
      final reminders = await reminderDatabase.getReminders();
      expect(reminders, isEmpty);
    });

    test('Delete reminder by medicament ID', () async {
      // Insert a new reminder
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,  // Medicament ID to be used for deletion
        intakeQuantity: 1,
        times: [TimeOfDay(hour: 8, minute: 0)],
      );
      await reminderDatabase.insertReminder(reminder);

      // Delete the reminder by medicament ID
      final rowsDeleted = await reminderDatabase.deleteReminderByMedicamentId(123);
      expect(rowsDeleted, 1);

      // Try to retrieve the deleted reminder
      final retrievedReminder = await reminderDatabase.getReminderById(myReminderId);
      expect(retrievedReminder, isNull);
    });

    test('Get reminder cards by reminder ID', () async {
      // Insert a reminder
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 1,
        times: [TimeOfDay(hour: 8, minute: 0)],
      );
      await reminderDatabase.insertReminder(reminder);

      // Insert a reminder card
      final reminderCard = ReminderCard(
        cardId: 'testCardId',
        reminderId: myReminderId,
        day: DateTime.now(),
        time: TimeOfDay(hour: 8, minute: 0),
        intakeQuantity: 1,
        isTaken: false,
        isJumped: false,
      );
      await reminderDatabase.insertReminderCard(reminderCard);

      // Now get reminder cards by reminder ID
      final reminderCards = await reminderDatabase.getReminderCardsByReminderId(myReminderId);
      expect(reminderCards, isNotEmpty);
    });

    test('Get reminder cards for selected day', () async {
      // Insert a reminder
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 1,
        times: [TimeOfDay(hour: 8, minute: 0)],
      );
      await reminderDatabase.insertReminder(reminder);

      // Insert a reminder card
      final reminderCard = ReminderCard(
        cardId: 'testCardId',
        reminderId: myReminderId,
        day: DateTime(2023, 1, 1),
        time: TimeOfDay(hour: 8, minute: 0),
        intakeQuantity: 1,
        isTaken: false,
        isJumped: false,
      );
      await reminderDatabase.insertReminderCard(reminderCard);

      // Now get reminder cards for selected day
      final reminderCards = await reminderDatabase.getReminderCardsForSelectedDay(myReminderId, DateTime(2023, 1, 1));
      expect(reminderCards, isNotEmpty);
    });

    test('Delete reminder cards by reminder ID', () async {
      // Insert a reminder
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 1,
        times: [TimeOfDay(hour: 8, minute: 0)],
      );
      await reminderDatabase.insertReminder(reminder);

      // Insert a reminder card
      final reminderCard = ReminderCard(
        cardId: 'testCardId',
        reminderId: myReminderId,
        day: DateTime.now(),
        time: TimeOfDay(hour: 8, minute: 0),
        intakeQuantity: 1,
        isTaken: false,
        isJumped: false,
      );
      await reminderDatabase.insertReminderCard(reminderCard);

      // Now delete reminder cards by reminder ID
      final rowsDeleted = await reminderDatabase.deleteReminderCardsByReminderId(myReminderId);
      expect(rowsDeleted, 1);
    });

    test('Update reminder cards', () async {
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,
        intakeQuantity: 2,
        times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)],
      );

      await reminderDatabase.updateReminderCards(reminder);
      final reminderCards = await reminderDatabase.getReminderCardsByReminderId(myReminderId);
      expect(reminderCards, isNotEmpty);
    });

    test('Delete reminder by medicament ID', () async {
      // Insert a new reminder
      final reminder = Reminder(
        id: myReminderId,
        reminderName: 'Test Reminder',
        selectedDays: [true, false, true, false, true, false, true],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        medicament: 123,  // Medicament ID to be used for deletion
        intakeQuantity: 1,
        times: [TimeOfDay(hour: 8, minute: 0)],
      );

      final insertedId = await reminderDatabase.insertReminder(reminder);
      expect(insertedId, myReminderId);

      // Delete the reminder by medicament ID
      final rowsDeleted = await reminderDatabase.deleteReminderByMedicamentId(123);
      expect(rowsDeleted, 1);

      // Try to retrieve the deleted reminder
      final retrievedReminder = await reminderDatabase.getReminderById(myReminderId);
      expect(retrievedReminder, isNull);
    });
  });
}