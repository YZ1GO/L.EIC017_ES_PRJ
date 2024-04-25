import 'package:app/reminders.dart';
import 'package:app/widgets/system_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'navigation_menu.dart';
import 'package:app/medicaments.dart';
import 'package:app/env/env.dart';

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