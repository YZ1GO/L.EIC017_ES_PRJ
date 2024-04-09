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
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();

    initialPage = selectedDate.difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    pageController = PageController(initialPage: initialPage, viewportFraction: 0.14);

    pageController.addListener(() {
      // Calculate the new selectedDate based on the current page
      final newPageIndex = pageController.page!.round();
      final newSelectedDate = DateTime(DateTime.now().year, 1, 1).add(Duration(days: newPageIndex));

      // Update selectedDate if it's changed
      if (newSelectedDate != selectedDate) {
        setState(() {
          selectedDate = newSelectedDate;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Specifics of the selected day
        Positioned(
            top: 60,
            left: 25,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align month with day of week
                  children: [
                    Text(
                      getDayOfWeekComplete(selectedDate.weekday),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${getMonth(selectedDate.month)} ${selectedDate.day}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(132, 48, 0, 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ),
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
                controller: pageController,
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(Duration(days: initialPage - index));
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: () {
                        scrollToDate(date);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Day of the week
                          FittedBox(
                            fit: BoxFit.none,
                            child: Text(
                              getDayOfWeek(date.weekday),
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.025,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open_Sans',
                                color: const Color.fromRGBO(255, 244, 236, 1),
                              ),
                            ),
                          ),
                          // Day of the month inside a circle
                          Container(
                            width: MediaQuery.of(context).size.width / 7,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: date.isAfter(DateTime.now()) ?
                              const Color.fromRGBO(253, 165, 108, 1) : const Color.fromRGBO(255, 244, 236, 1),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.none,
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'Open_Sans',
                                    color: date.isAfter(DateTime.now()) ?
                                    Colors.black.withOpacity(0.5) : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  // Function to scroll calendar to tapped day
  void scrollToDate(DateTime date) {
    final pageIndex = date.difference(DateTime(date.year, 1, 1)).inDays;
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
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

  // Function to get the day of the week
  String getDayOfWeekComplete(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
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