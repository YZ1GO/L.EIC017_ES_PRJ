import 'package:app/env/env.dart';
import 'package:app/main.dart';
import 'package:app/medicaments.dart';
import 'package:app/reminders.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';

Future<void> initializeTestEnvironment() async {
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
}

/// Usage: the user is in "Stock Screen"
Future<void> theUserIsInStockScreen(WidgetTester tester) async {
  await initializeTestEnvironment();
  await tester.pumpWidget(MyApp());
  await tester.tap(find.byKey(Key('stock screen button')));
  await tester.pumpAndSettle();
}
