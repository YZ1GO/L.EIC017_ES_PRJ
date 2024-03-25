import 'package:flutter/material.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/system_notification_test_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}
class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          Positioned(
            left: (MediaQuery.of(context).size.width - 801) / 2, // Adjust position to center horizontally
            top: -268,
            child: ClipOval(
              child: Container(
                width: 801,
                height: 553,
                color: const Color.fromRGBO(225, 95, 0, 1),
              ),
            ),
          ),
          const CalendarWidget(),
          const SystemNotificationWidget(),
        ],
      ),
    );
  }
}
