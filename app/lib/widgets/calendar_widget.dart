import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  // Calculate the initial page index based on today's date
  late int initialPage;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    initialPage = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    pageController = PageController(initialPage: initialPage, viewportFraction: 0.14);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Box in the center of calendar
        Positioned(
          left: (MediaQuery.of(context).size.width - 58) / 2,
          top: 140,
          child: Container(
            width: 60,
            height: 70,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(188, 73, 0, 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Calendar
        Positioned(
          left: 0,
          right: 0,
          top: 125,
          child: Center(
            child: SizedBox(
              height: 100,
              child: PageView.builder(
                itemCount: null, // Infinite scrolling
                controller: PageController(
                  initialPage: initialPage,
                  viewportFraction: 0.14,
                ),
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(Duration(days: initialPage - index));
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day of the week
                        Text(
                          getDayOfWeek(date.weekday),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(255, 244, 236, 1)
                          ),
                        ),
                        // Day of the month inside a circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: date.isAfter(DateTime.now()) ?
                            const Color.fromRGBO(253, 165, 108, 1) : const Color.fromRGBO(255, 244, 236, 1),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: date.isAfter(DateTime.now()) ?
                                Colors.black.withOpacity(0.5) : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Function to get the day of the week abbreviation
  String getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'MON';
      case 2:
        return 'TUE';
      case 3:
        return 'WED';
      case 4:
        return 'THU';
      case 5:
        return 'FRI';
      case 6:
        return 'SAT';
      case 7:
        return 'SUN';
      default:
        return '';
    }
  }

  // Function to get the month
  String getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}