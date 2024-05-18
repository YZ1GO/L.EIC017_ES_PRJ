import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app/model/medicaments.dart';
import 'dart:async';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
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

  var tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

  if (tzScheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
    try {
      print('Scheduling notification with the following details:');
      print('ID: $id');
      print('Title: $title');
      print('Body: $body');
      print('Scheduled Date: $tzScheduledDate');
      print('Current Date: ${DateTime.now()}');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      //printScheduledNotifications();
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}

Future<void> printScheduledNotifications() async {
  final List<PendingNotificationRequest> pendingNotifications =
  await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  for (var notification in pendingNotifications) {
    print('Notification ID: ${notification.id}');
    print('Notification Title: ${notification.title}');
    print('Notification Body: ${notification.body}');
  }
}

void checkScheduledNotifications() async {
  final List<PendingNotificationRequest> pendingNotificationRequests =
  await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  print('TOTAL NOTIFICATIONS: ${pendingNotificationRequests.length}');
}

void cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

void cancelNotification(String cardId) async {
  int notificationId = cardId.hashCode.toUnsigned(31);
  await flutterLocalNotificationsPlugin.cancel(notificationId);
}