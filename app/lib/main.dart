import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'navigation_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyDbpqjXP_NGAngNv-M8wRPdeesCLRyGvcc',
        appId: '1:981114628978:android:606d661c3d68e159264beb',
        messagingSenderId: '981114628978',
        projectId: 'pingupills'
      )
  );
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