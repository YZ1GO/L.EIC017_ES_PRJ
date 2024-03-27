import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showControlCenter(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 239,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 65),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(225, 95, 0, 1),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  icon: Image.asset(
                    'assets/icons/alarm_icon.png',
                    width: 17,
                  ),
                  label: Text("Add reminder"),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(199, 84, 0, 1),
                    backgroundColor: Color.fromRGBO(255, 198, 157, 1),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  icon: Image.asset(
                    'assets/icons/calendar_icon.png',
                    width: 17,
                  ),
                  label: Text("Manage reminders"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
