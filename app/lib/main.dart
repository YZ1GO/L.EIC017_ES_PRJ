import 'package:app/model/reminders.dart';
import 'package:app/notifications/notification_checker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'navigation_menu.dart';
import 'package:app/database/local_stock.dart';
import 'package:app/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
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