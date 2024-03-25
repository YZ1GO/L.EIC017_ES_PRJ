import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class SystemNotificationWidget extends StatelessWidget {
  const SystemNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 300,
      child: ElevatedButton(
        onPressed: () async {
          await requestNotificationPermission(context);
        },
        child: const Text('Test Notification'),
      ),
    );
  }

  Future<void> requestNotificationPermission(BuildContext context) async {
    // Check if notification permission is granted
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      // If permission is not granted, show a dialog to request permission
      var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permission Required'),
            content: Text('Please grant permission to receive notifications'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Request notification permission
                  var status = await Permission.notification.request();
                  Navigator.of(context).pop(status.isGranted);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      // If user grants permission, show the notification
      if (result == true) {
        await showNotification();
      }
    } else {
      // If permission is already granted, show the notification
      await showNotification();
    }
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher', // flutter default icon
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(
        android: androidPlatformChannelSpecifics
    );
    await FlutterLocalNotificationsPlugin().show(
      0,
      'Test Notification',
      'Time to take medicine',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
