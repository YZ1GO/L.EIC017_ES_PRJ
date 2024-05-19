import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app/model/medicaments.dart';
import 'dart:async';
import '../database/local_stock.dart';
import '../model/reminders.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// NOTIFICATION SINGLE MEDICAMENT *
void notifyMedicamentCloseToExpire(Medicament medicament) async {
  String medicamentName = medicament.name;
  String title = '$medicamentName is close to its expiration date!';
  String body = 'Check if you need to use it before it expires';

  await showNotification(title, body);
}

void notifyMedicamentExpired(Medicament medicament) async {
  String medicamentName = medicament.name;
  String title = '$medicamentName has expired!';
  String body = 'Dispose of it properly';

  await showNotification(title, body);
}

void notifyMedicamentRunningLow(Medicament medicament) async {
  String title = 'Stock is Running Low!';
  String body;
  if (medicament.quantity == 1) {
    body = '${medicament.name} only has 1 piece remaining';
  } else if (medicament.quantity == 0) {
    body = '${medicament.name} is out of stock';
  } else {
    body = '${medicament.name} only has ${medicament.quantity} pieces remaining';
  }
  showNotification(title, body);
}

void notificationMedicationReminder(Medicament medicament, TimeOfDay timeToTakeMeds) async {
  int hour = timeToTakeMeds.hour;
  int minute = timeToTakeMeds.minute;
  String title = 'It\'s time to take your {$hour:$minute} meds!';
  String body = 'Don\'t forget to mark as taken';

  await showNotification(title, body);
}

/// NOTIFICATION HANDLER *
Future<void> showNotification(String notificationTitle, String notificationText) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'default_channel_id',
    'Default Channel',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: '@mipmap/launcher_icon',
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await FlutterLocalNotificationsPlugin().show(
    0,
    notificationTitle,
    notificationText,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

// Create a global map to store the timers
Map<String, Timer> timers = {};

Future<void> scheduleNotification(String cardId, String title, String body, DateTime scheduledDate) async {
  var timeDifference = scheduledDate.difference(DateTime.now());
  var milliseconds = timeDifference.inMilliseconds;

  if (milliseconds > 0) {
    Timer timer = Timer(Duration(milliseconds: milliseconds), () async {
      await showNotification(title, body);
      timers.remove(cardId); // Remove the timer from the map after it fires
    });

    // Store the timer in the map using the cardId as the key
    timers[cardId] = timer;
  }
}

void cancelTimer(String cardId) {
  Timer? timer = timers[cardId];
  if (timer != null) {
    timer.cancel();
    timers.remove(cardId);
  }
}

void cancelAllTimers() {
  timers.forEach((cardId, timer) {
    timer.cancel();
  });
  timers.clear();
}

Future<void> setTimersOnAppStart() async {
  // Fetch all reminders and set timers
  List<Reminder> reminders = await ReminderDatabase().getReminders();
  for (Reminder reminder in reminders) {
    List<ReminderCard> reminderCards = await ReminderDatabase().getReminderCardsByReminderId(reminder.id);
    for (ReminderCard reminderCard in reminderCards) {

      DateTime reminderDateTime = DateTime(reminderCard.day.year, reminderCard.day.month, reminderCard.day.day, reminderCard.time.hour, reminderCard.time.minute);

      // If the reminder DateTime is in the future, schedule a notification
      if (reminderDateTime.isAfter(DateTime.now())) {
        Medicament? medicament = await MedicamentStock().getMedicamentById(reminder.medicament);
        String message = reminder.reminderName == '' ? 'It\'s time to take your medicament!' : reminder.reminderName;
        scheduleNotification(reminderCard.cardId, medicament!.name, message, reminderDateTime);
      }
    }
  }
}