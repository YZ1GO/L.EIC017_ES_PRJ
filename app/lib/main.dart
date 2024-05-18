import 'package:app/model/reminders.dart';
import 'package:app/notifications/notification_checker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'navigation_menu.dart';
import 'package:app/database/local_stock.dart';
import 'package:app/env/env.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notifications/system_notification.dart';

Future<void> _initializeNotification() async {
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Env.API_KEY,
      appId: Env.APP_ID,
      messagingSenderId: Env.MESSAGING_SENDER_ID,
      projectId: Env.PROJECT_ID
    )
  );
  await ReminderDatabase().initDatabase();
  await MedicamentStock().initDatabase();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  checkDayChangeInit();
  await _initializeNotification();
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PinguPills',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const NavigationMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}