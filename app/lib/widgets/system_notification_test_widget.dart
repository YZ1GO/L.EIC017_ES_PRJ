import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SystemNotificationWidget extends StatelessWidget {
  const SystemNotificationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Positioned(
        top: 300,
        child: ElevatedButton(
          onPressed: () {
            showNotification();
          },
          child: const Text('Test Notification'),
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.5),
            backgroundColor: Color.fromRGBO(255, 131, 41, 1),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
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
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await FlutterLocalNotificationsPlugin().show(
      0,
      'Test Notification',
      'Time to take medicine',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
