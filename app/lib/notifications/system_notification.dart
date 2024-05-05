import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app/model/medicaments.dart';
import 'dart:async';

/** NOTIFICATION SINGLE MEDICAMENT **/
void notifyMedicamentCloseToExpire(Medicament medicament) async {
  String medicamentName = medicament.name;
  String title = '$medicamentName is close to its expiration date!';
  String body = 'Check if you need to use it before it expires';

  print('{$medicamentName} is close to expiry date');
  await showNotification(title, body);
}

void notifyMedicamentExpired(Medicament medicament) async {
  String medicamentName = medicament.name;
  String title = '$medicamentName has expired!';
  String body = 'Dispose of it properly';

  print('{$medicamentName} is expired');
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

/** NOTIFICATION HANDLER **/
Future<void> showNotification(String notification_title, String notification_text) async {
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
    notification_title,
    notification_text,
    platformChannelSpecifics,
    payload: 'item x',
  );
}
