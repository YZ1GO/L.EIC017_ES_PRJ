import 'package:app/reminders.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'navigation_menu.dart';
import 'package:app/medicaments.dart';
import 'package:app/database/env.dart';

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
  await MedicamentStock().initDatabase();
  await ReminderDatabase().initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertical Prototype',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NavigationMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}